#!/usr/bin/env node
// claude-dash — live, cross-project view of ALL Claude Code sessions.
//
// Unlike the built-in `claude agents` TUI (scoped to the current project) or a
// tmux-pane scraper (only sees sessions with a visible pane), this polls
// `claude agents --json --all` — every session across every project, including
// completed ones — and pins the sessions waiting on you at the top.
//
// Groups, in order:
//     ⏳ WAITING ON YOU   status == "waiting"   (shows what it needs)
//     🔵 WORKING          status == "busy"
//     💤 IDLE             status == "idle"
//     ✅ DONE             terminal state (done/failed/exited/…)
//
// Usage: claude-dash [--once]
// Env:   CLAUDE_DASH_INTERVAL=seconds (default 3)
// Keys:  q / Ctrl-C to quit.

"use strict";
const { execFile, execFileSync } = require("child_process");

const INTERVAL = Number(process.env.CLAUDE_DASH_INTERVAL || "3") || 3;

// ANSI — mirrors the look of the original bash claude-dash.
const R = "\x1b[0m", B = "\x1b[1m", DIM = "\x1b[2m";
const RED = "\x1b[31m", YEL = "\x1b[33m", GRN = "\x1b[32m", CYN = "\x1b[36m";

const TERMINAL_STATES = new Set([
  "done", "failed", "exited", "completed", "error", "killed", "cancelled", "canceled",
]);

// { key, emoji, title, ilabel (icon label), color }
const GROUPS = [
  { key: "waiting", emoji: "⏳", title: "WAITING ON YOU", ilabel: "● needs you", color: RED },
  { key: "busy",    emoji: "🔵", title: "WORKING",        ilabel: "● working",   color: YEL },
  { key: "idle",    emoji: "💤", title: "IDLE",           ilabel: "● idle",      color: GRN },
  { key: "done",    emoji: "✅", title: "DONE",           ilabel: "● done",      color: DIM },
];
const ICON_W = Math.max(...GROUPS.map((g) => g.ilabel.length)); // align status labels

function classify(s) {
  const status = s.status;
  const state = String(s.state || "").toLowerCase();
  if (status === "waiting") return "waiting";
  if (TERMINAL_STATES.has(state)) return "done";
  if (status === "busy") return "busy";
  if (status === "idle") return "idle";
  // Unknown/missing status with no terminal state — surface as idle.
  return "idle";
}

function relAge(startedMs, nowMs = Date.now()) {
  const n = Number(startedMs);
  if (!Number.isFinite(n)) return "?";
  const secs = Math.max(0, (nowMs - n) / 1000);
  if (secs < 60) return `${Math.floor(secs)}s`;
  if (secs < 3600) return `${Math.floor(secs / 60)}m`;
  if (secs < 86400) return `${Math.floor(secs / 3600)}h`;
  return `${Math.floor(secs / 86400)}d`;
}

function project(s) {
  let cwd = String(s.cwd || "").replace(/\/+$/, "");
  if (!cwd) return "?";
  // Claude worktrees nest under <project>/.claude/worktrees/<branch>; use the
  // repo dir, not the branch dir.
  const wt = cwd.indexOf("/.claude/worktrees/");
  if (wt !== -1) cwd = cwd.slice(0, wt);
  let name = cwd.split("/").pop() || cwd;
  // Sibling worktree dirs are named <project>-<JIRA-TICKET>-...; drop that
  // suffix so the column is always the bare project name.
  name = name.replace(/-[A-Z]{2,}-\d+.*$/, "") || name;
  return name;
}

function trunc(text, width) {
  text = String(text).replace(/\n/g, " ");
  if (text.length <= width) return text;
  return text.slice(0, Math.max(0, width - 1)) + "…";
}

// A tmux pane running Claude prefixes its title with a status glyph/spinner
// (e.g. "✳ " or "⠐ "). Strip leading non-letter/number symbols so the title
// reads as a plain description.
function cleanTitle(t) {
  if (!t) return "";
  return String(t).replace(/^[^\p{L}\p{N}"'(\[]+/u, "").trim();
}

// Visible display width: strips ANSI and counts double-width glyphs (the group
// emoji, CJK) as 2 so the box border lines up instead of overrunning/wrapping.
function dwidth(str) {
  str = str.replace(/\x1b\[[0-9;]*m/g, "");
  let w = 0;
  for (const ch of str) {
    const cp = ch.codePointAt(0);
    if (cp === 0x200d || (cp >= 0xfe00 && cp <= 0xfe0f)) continue; // ZWJ / variation selectors
    const wide =
      (cp >= 0x1100 && cp <= 0x115f) || (cp >= 0x2e80 && cp <= 0xa4cf) ||
      (cp >= 0xac00 && cp <= 0xd7a3) || (cp >= 0xf900 && cp <= 0xfaff) ||
      (cp >= 0xff00 && cp <= 0xff60) || (cp >= 0x1f000 && cp <= 0x1ffff) ||
      (cp >= 0x2600 && cp <= 0x27bf) || (cp >= 0x2b00 && cp <= 0x2bff) ||
      (cp >= 0x23e9 && cp <= 0x23fa) || cp === 0x2705 || cp === 0x231a || cp === 0x231b;
    w += wide ? 2 : 1;
  }
  return w;
}

function padEnd(str, width) {
  return str.length >= width ? str : str + " ".repeat(width - str.length);
}

// Run `claude agents --json --all`; resolves to { sessions, err }. Never rejects.
function fetch() {
  return new Promise((resolve) => {
    execFile(
      "claude",
      ["agents", "--json", "--all"],
      { timeout: 15000, maxBuffer: 16 * 1024 * 1024 },
      (error, stdout, stderr) => {
        if (error) {
          if (error.code === "ENOENT") return resolve({ sessions: [], err: "`claude` not found on PATH" });
          if (error.killed) return resolve({ sessions: [], err: "claude agents timed out" });
          const msg = String(stderr || stdout || error.message).trim().split("\n")[0];
          return resolve({ sessions: [], err: `claude failed: ${msg}` });
        }
        let data;
        try {
          data = JSON.parse(stdout || "[]");
        } catch {
          return resolve({ sessions: [], err: "malformed JSON from claude agents" });
        }
        if (!Array.isArray(data)) return resolve({ sessions: [], err: "unexpected JSON shape from claude agents" });
        resolve({ sessions: data.filter((s) => s && typeof s === "object"), err: null });
      }
    );
  });
}

function clock() {
  return new Date().toTimeString().slice(0, 8); // HH:MM:SS, local time
}

// Bucket sessions by group key, each sorted newest-first. Pure.
function groupSessions(sessions) {
  const buckets = {};
  for (const g of GROUPS) buckets[g.key] = [];
  for (const s of sessions) buckets[classify(s)].push(s);
  for (const key of Object.keys(buckets)) {
    // newest first; the waiting group is already pinned on top by section order.
    buckets[key].sort((a, b) => (Number(b.startedAt) || 0) - (Number(a.startedAt) || 0));
  }
  return buckets;
}

// Flat list of sessions in the exact order they're drawn (the selectable rows).
// Mirrors formatView's group/row iteration so an index maps to the same row.
function orderedSessions(sessions) {
  const buckets = groupSessions(sessions);
  const out = [];
  for (const g of GROUPS) out.push(...buckets[g.key]);
  return out;
}

// Stable identity for a session, used to keep the selection on the same session
// across refreshes even if the list reorders.
function sessionKey(s) {
  return String(s.sessionId || s.id || s.pid || "");
}

// Walk a pid up its process-parent chain until it matches a tmux pane's shell
// pid; return that pane's id (e.g. "%7"), or null if it isn't inside a pane.
// Pure: the pane and parent maps are injected so this is unit-testable.
function findPaneForPid(pid, paneByShellPid, parentByPid) {
  let cur = Number(pid);
  for (let hops = 0; cur > 1 && hops < 30; hops++) {
    if (paneByShellPid.has(cur)) return paneByShellPid.get(cur);
    if (!parentByPid.has(cur)) break;
    cur = parentByPid.get(cur);
  }
  return null;
}

// Build the full screen string. Pure: no I/O, time/width are injected.
// selectedIndex marks the highlighted row (index into orderedSessions); -1 = none.
function formatView({ sessions, err }, cols, nowMs, ts, selectedIndex = -1) {
  const buckets = groupSessions(sessions);
  let rowIdx = -1;

  const lines = [];
  const counts = GROUPS.map((g) => `${g.emoji}${buckets[g.key].length}`).join("  ");
  const head = `┌─ Claude sessions ─  ${counts}  `;
  const fill = Math.max(2, cols - dwidth(head) - ts.length - 6);
  lines.push(`${B}${head}${"─".repeat(fill)}  ${ts}  ─┐${R}`);

  if (err) {
    lines.push(`  ${RED}⚠ ${err}${R}`);
  } else if (sessions.length === 0) {
    lines.push(`  ${DIM}(no Claude sessions detected)${R}`);
  } else {
    const projW = Math.min(24, Math.max(8, ...sessions.map((s) => project(s).length)));
    for (const g of GROUPS) {
      const rows = buckets[g.key];
      if (rows.length === 0) continue;
      lines.push("");
      lines.push(`  ${B}${g.emoji} ${g.title}${R} ${DIM}(${rows.length})${R}`);
      for (const s of rows) {
        rowIdx++;
        const sel = rowIdx === selectedIndex;
        const gutter = sel ? `${B}${CYN}❯${R} ` : "  "; // 2 cols either way
        const icon = `${g.color}${padEnd(g.ilabel, ICON_W)}${R}`;
        const proj = `${CYN}${padEnd(trunc(project(s), projW), projW)}${R}`;
        // Label: explicit name, else the tmux pane title, else the short id.
        const name = s.name || s.paneTitle || String(s.sessionId || "").slice(0, 8);
        const age = relAge(s.startedAt, nowMs);
        // Waiting/done rows reserve room for their detail column; others give
        // the whole remaining width to the (often long) description.
        const hasDetail = g.key === "waiting" || g.key === "done";
        const fixed = ICON_W + projW + 12;
        const nameBudget = hasDetail
          ? Math.max(10, Math.floor((cols - fixed) / 2))
          : Math.max(10, cols - fixed);
        const nameS = trunc(name, nameBudget);
        let detailText = "", detailColor = "";
        if (g.key === "waiting") {
          detailText = s.waitingFor || "waiting for input";
          detailColor = YEL;
        } else if (g.key === "done") {
          detailText = String(s.state || "done").toLowerCase();
          detailColor = ["failed", "error", "killed"].includes(detailText) ? RED : DIM;
        }
        // Clamp the detail to whatever room is left so a row never wraps.
        const used = 4 + ICON_W + 2 + projW + 1 + nameS.length + 1 + 4 + 2;
        if (detailText && cols - used < detailText.length) {
          detailText = trunc(detailText, Math.max(3, cols - used));
        }
        let row = `${gutter}  ${icon}  ${proj} ${nameS} ${DIM}${age.padStart(4)}${R}`;
        if (detailText) row += `  ${detailColor}${detailText}${R}`;
        lines.push(row);
      }
    }
  }

  lines.push("");
  const keys = `${DIM}└── ${B}j/k${R}${DIM} move · ${B}↵${R}${DIM} open in tmux · ${B}q${R}${DIM} quit`;
  const colorKey = `   ·   ${RED}●${DIM} needs ${YEL}●${DIM} working ${GRN}●${DIM} idle ${DIM}● done`;
  // Append the color key only if the whole legend still fits the width.
  lines.push((dwidth(keys + colorKey) <= cols ? keys + colorKey : keys) + R);
  return lines.join("\n");
}

// Fetch sessions and annotate them with tmux pane info (title for the label,
// pane id for the jump).
async function liveData() {
  const result = await fetch();
  if (!result.err) enrichSessions(result.sessions);
  return result;
}

// Live wrapper: fetch+enrich data + inject real terminal width and clock.
async function render() {
  const cols = Math.max(60, process.stdout.columns || 100);
  return formatView(await liveData(), cols, Date.now(), clock());
}

// One tmux call -> { shellToPane: pane shell pid -> pane id,
//                     titleByPane: pane id -> pane title }.
function paneInfo() {
  const shellToPane = new Map();
  const titleByPane = new Map();
  try {
    const out = execFileSync(
      "tmux",
      ["list-panes", "-a", "-F", "#{pane_pid}\t#{pane_id}\t#{pane_title}"],
      { encoding: "utf8" }
    );
    for (const line of out.split("\n")) {
      if (!line) continue;
      const [pid, id, ...rest] = line.split("\t");
      if (pid && id) {
        shellToPane.set(Number(pid), id);
        titleByPane.set(id, rest.join("\t"));
      }
    }
  } catch {}
  return { shellToPane, titleByPane };
}

// Annotate each session with its hosting tmux pane id and a cleaned pane title
// (used as the row description when the session has no explicit name).
function enrichSessions(sessions) {
  const { shellToPane, titleByPane } = paneInfo();
  const parents = parentMap();
  for (const s of sessions) {
    const pane = s.pid ? findPaneForPid(s.pid, shellToPane, parents) : null;
    if (!pane) continue;
    s.paneId = pane;
    const t = cleanTitle(titleByPane.get(pane));
    if (t && t !== "claude.exe") s.paneTitle = t;
  }
  return sessions;
}

// Map pid -> ppid for every process (one ps call).
function parentMap() {
  const map = new Map();
  try {
    const out = execFileSync("ps", ["-ax", "-o", "pid=,ppid="], { encoding: "utf8" });
    for (const line of out.trim().split("\n")) {
      const m = line.trim().split(/\s+/);
      if (m.length >= 2) map.set(Number(m[0]), Number(m[1]));
    }
  } catch {}
  return map;
}

// Resolve the tmux pane id hosting a session, or null if it isn't in a pane.
function resolvePaneTarget(session) {
  if (!session || !session.pid) return null;
  return findPaneForPid(session.pid, paneInfo().shellToPane, parentMap());
}

// Focus a pane and switch the current client to it.
function jumpToPane(paneId) {
  execFileSync("tmux", ["select-pane", "-t", paneId]);
  execFileSync("tmux", ["select-window", "-t", paneId]);
  execFileSync("tmux", ["switch-client", "-t", paneId]);
}

function draw(body) {
  // Clear + home, then paint. Avoids the flicker/scroll of a full clear.
  process.stdout.write("\x1b[H\x1b[J" + body + "\n");
}

async function main() {
  if (process.argv.slice(2).includes("--once")) {
    process.stdout.write((await render()) + "\n");
    return;
  }

  const interactive = process.stdin.isTTY;
  let stopped = false;
  let timer = null;

  // Interaction state. `data` is the last fetch; `selKey` keeps the cursor on
  // the same session across refreshes; `ordered` is the last drawn row order.
  const state = { data: { sessions: [], err: null }, selKey: null, ordered: [], flash: "" };

  function cleanup() {
    if (stopped) return;
    stopped = true;
    if (timer) clearTimeout(timer);
    if (interactive) {
      try { process.stdin.setRawMode(false); } catch {}
      process.stdin.pause();
    }
    process.stdout.write("\x1b[?25h"); // show cursor
  }

  function quit() {
    cleanup();
    process.exit(0);
  }

  // Paint from current state (no refetch). Resolves the selected index from
  // selKey, clamping to the list, and keeps the order for the key handlers.
  function repaint() {
    const cols = Math.max(60, process.stdout.columns || 100);
    const ordered = orderedSessions(state.data.sessions);
    state.ordered = ordered;
    let idx = ordered.findIndex((s) => sessionKey(s) === state.selKey);
    if (idx < 0) idx = ordered.length ? 0 : -1;
    state.selKey = idx >= 0 ? sessionKey(ordered[idx]) : null;
    let body = formatView(state.data, cols, Date.now(), clock(), idx);
    if (state.flash) body += `\n${RED}${state.flash}${R}`;
    draw(body);
    return idx;
  }

  function move(delta) {
    const n = state.ordered.length;
    if (!n) return;
    let idx = state.ordered.findIndex((s) => sessionKey(s) === state.selKey);
    if (idx < 0) idx = 0;
    idx = Math.max(0, Math.min(n - 1, idx + delta));
    state.selKey = sessionKey(state.ordered[idx]);
    state.flash = "";
    repaint();
  }

  function openSelected() {
    const idx = state.ordered.findIndex((s) => sessionKey(s) === state.selKey);
    const sess = idx >= 0 ? state.ordered[idx] : null;
    if (!sess) return;
    const pane = sess.paneId || resolvePaneTarget(sess);
    if (!pane) {
      state.flash = "⚠ no tmux window found for this session (background or not in tmux)";
      repaint();
      return;
    }
    cleanup();
    try { jumpToPane(pane); } catch {}
    process.exit(0); // closes the popup; client lands on the target pane
  }

  if (interactive) {
    process.stdin.setRawMode(true);
    process.stdin.resume();
    process.stdin.on("data", (buf) => {
      const ch = buf.toString();
      if (ch === "q" || ch === "Q" || ch === "\x03") return quit(); // q / Ctrl-C
      if (ch === "j" || ch === "\x1b[B") return move(1); // j / down arrow
      if (ch === "k" || ch === "\x1b[A") return move(-1); // k / up arrow
      if (ch === "\r" || ch === "\n") return openSelected(); // Enter
    });
  }
  process.on("SIGINT", quit);
  process.on("SIGTERM", quit);

  process.stdout.write("\x1b[?25l"); // hide cursor

  // Redraw immediately when the pane resizes (e.g. on attach/popup open).
  if (process.stdout.isTTY) {
    process.stdout.on("resize", () => { if (!stopped) repaint(); });
  }

  // Refetch on an interval; key handlers repaint instantly from cached state.
  async function tick() {
    if (stopped) return;
    state.data = await liveData();
    repaint();
    if (!stopped) timer = setTimeout(tick, INTERVAL * 1000);
  }
  await tick();
}

// --emit-tmux: stamp every tmux window with the status of the Claude session it
// hosts into a per-window @claude_status option (waiting|busy|idle|done, or unset
// when the window hosts no Claude). The window-status glyph reads this option; see
// tmux.conf and tmux-claude-glyph.sh. Prints nothing — it is invoked from a
// zero-width status-right #() so it re-runs on each status redraw. When a window
// hosts several sessions the most attention-worthy status wins.
const STATUS_RANK = { waiting: 4, idle: 3, busy: 2, done: 1 };
async function emitTmux() {
  const { sessions, err } = await fetch();
  if (err) return; // transient failure: leave existing options untouched
  enrichSessions(sessions); // annotates each session with .paneId
  const paneToWin = new Map();
  const allWins = new Set();
  try {
    const out = execFileSync("tmux", ["list-panes", "-a", "-F", "#{pane_id}\t#{window_id}"], { encoding: "utf8" });
    for (const line of out.split("\n")) {
      if (!line) continue;
      const [pane, win] = line.split("\t");
      if (pane && win) { paneToWin.set(pane, win); allWins.add(win); }
    }
  } catch { return; }
  const winStatus = new Map();
  for (const s of sessions) {
    const win = s.paneId ? paneToWin.get(s.paneId) : null;
    if (!win) continue;
    const key = classify(s);
    const cur = winStatus.get(win);
    if (!cur || STATUS_RANK[key] > STATUS_RANK[cur]) winStatus.set(win, key);
  }
  for (const win of allWins) {
    const want = winStatus.get(win) || "";
    let have = "";
    try { have = execFileSync("tmux", ["show-options", "-wqv", "-t", win, "@claude_status"], { encoding: "utf8" }).trim(); } catch {}
    if (want === have) continue; // avoid needless set-option churn / redraw loops
    try {
      if (want) execFileSync("tmux", ["set-option", "-w", "-t", win, "@claude_status", want]);
      else execFileSync("tmux", ["set-option", "-u", "-w", "-t", win, "@claude_status"]);
    } catch {}
  }
}

// Run the TUI only when executed directly; stay quiet when imported (tests).
if (require.main === module) {
  if (process.argv.includes("--emit-tmux")) {
    emitTmux().catch(() => {}).finally(() => process.exit(0));
  } else {
    main().catch((e) => {
      process.stdout.write("\x1b[?25h");
      console.error(e && e.stack ? e.stack : String(e));
      process.exit(1);
    });
  }
}

module.exports = {
  GROUPS,
  classify,
  relAge,
  project,
  trunc,
  cleanTitle,
  dwidth,
  padEnd,
  groupSessions,
  orderedSessions,
  sessionKey,
  findPaneForPid,
  formatView,
};
