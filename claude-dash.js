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
const { execFile } = require("child_process");

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

function relAge(startedMs) {
  const n = Number(startedMs);
  if (!Number.isFinite(n)) return "?";
  const secs = Math.max(0, Date.now() / 1000 - n / 1000);
  if (secs < 60) return `${Math.floor(secs)}s`;
  if (secs < 3600) return `${Math.floor(secs / 60)}m`;
  if (secs < 86400) return `${Math.floor(secs / 3600)}h`;
  return `${Math.floor(secs / 86400)}d`;
}

function project(s) {
  const cwd = String(s.cwd || "").replace(/\/+$/, "");
  if (!cwd) return "?";
  // Worktrees nest under .claude/worktrees/<name>; the basename is the useful bit.
  return cwd.split("/").pop() || cwd;
}

function trunc(text, width) {
  text = String(text).replace(/\n/g, " ");
  if (text.length <= width) return text;
  return text.slice(0, Math.max(0, width - 1)) + "…";
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

async function render() {
  let cols = process.stdout.columns || 100;
  cols = Math.max(60, cols);
  const { sessions, err } = await fetch();

  const buckets = {};
  for (const g of GROUPS) buckets[g.key] = [];
  for (const s of sessions) buckets[classify(s)].push(s);
  for (const key of Object.keys(buckets)) {
    // newest first; the waiting group is already pinned on top by section order.
    buckets[key].sort((a, b) => (Number(b.startedAt) || 0) - (Number(a.startedAt) || 0));
  }

  const lines = [];
  const counts = GROUPS.map((g) => `${g.emoji}${buckets[g.key].length}`).join("  ");
  const ts = clock();
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
        const icon = `${g.color}${padEnd(g.ilabel, ICON_W)}${R}`;
        const proj = `${CYN}${padEnd(trunc(project(s), projW), projW)}${R}`;
        const name = s.name || String(s.sessionId || "").slice(0, 8);
        const age = relAge(s.startedAt);
        const nameBudget = Math.max(10, Math.floor((cols - (ICON_W + 3) - (projW + 1) - 8) / 2));
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
        let row = `    ${icon}  ${proj} ${nameS} ${DIM}${age.padStart(4)}${R}`;
        if (detailText) row += `  ${detailColor}${detailText}${R}`;
        lines.push(row);
      }
    }
  }

  lines.push("");
  lines.push(
    `${DIM}└── ${RED}●${DIM} needs you  ${YEL}●${DIM} working  ${GRN}●${DIM} idle  ` +
      `${DIM}●${DIM} done   ·  refresh ${INTERVAL}s · q / Ctrl-C to quit${R}`
  );
  return lines.join("\n");
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

  if (interactive) {
    process.stdin.setRawMode(true);
    process.stdin.resume();
    process.stdin.on("data", (buf) => {
      const ch = buf.toString();
      if (ch === "q" || ch === "Q" || ch === "\x03") quit(); // q or Ctrl-C
    });
  }
  process.on("SIGINT", quit);
  process.on("SIGTERM", quit);

  process.stdout.write("\x1b[?25l"); // hide cursor

  // Redraw immediately when the pane resizes (e.g. when you attach the session).
  if (process.stdout.isTTY) {
    process.stdout.on("resize", () => {
      if (!stopped) render().then(draw);
    });
  }

  async function tick() {
    if (stopped) return;
    draw(await render());
    if (!stopped) timer = setTimeout(tick, INTERVAL * 1000);
  }
  await tick();
}

main().catch((e) => {
  process.stdout.write("\x1b[?25h");
  console.error(e && e.stack ? e.stack : String(e));
  process.exit(1);
});
