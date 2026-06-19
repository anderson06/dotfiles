import { describe, it, expect } from "vitest";
import {
  classify,
  relAge,
  project,
  trunc,
  dwidth,
  groupSessions,
  orderedSessions,
  sessionKey,
  findPaneForPid,
  formatView,
} from "./claude-dash.js";

// Strip ANSI so assertions read against the visible text only.
const plain = (s) => s.replace(/\x1b\[[0-9;]*m/g, "");

describe("classify", () => {
  it("maps status to its group", () => {
    expect(classify({ status: "waiting" })).toBe("waiting");
    expect(classify({ status: "busy" })).toBe("busy");
    expect(classify({ status: "idle" })).toBe("idle");
  });

  it("treats a terminal state as done, even when status is idle", () => {
    expect(classify({ status: "idle", state: "done" })).toBe("done");
    expect(classify({ state: "failed" })).toBe("done");
    expect(classify({ state: "EXITED" })).toBe("done"); // case-insensitive
  });

  it("waiting takes precedence over everything", () => {
    expect(classify({ status: "waiting", state: "done" })).toBe("waiting");
  });

  it("falls back to idle for missing/unknown status", () => {
    expect(classify({})).toBe("idle");
    expect(classify({ status: "weird" })).toBe("idle");
  });
});

describe("relAge", () => {
  const now = 1_000_000_000_000;
  it("formats seconds / minutes / hours / days", () => {
    expect(relAge(now - 5_000, now)).toBe("5s");
    expect(relAge(now - 5 * 60_000, now)).toBe("5m");
    expect(relAge(now - 3 * 3_600_000, now)).toBe("3h");
    expect(relAge(now - 2 * 86_400_000, now)).toBe("2d");
  });

  it("never goes negative and handles bad input", () => {
    expect(relAge(now + 10_000, now)).toBe("0s");
    expect(relAge(undefined, now)).toBe("?");
    expect(relAge("not-a-number", now)).toBe("?");
  });
});

describe("project", () => {
  it("returns the cwd basename", () => {
    expect(project({ cwd: "/Users/me/dev/website" })).toBe("website");
  });
  it("ignores a trailing slash", () => {
    expect(project({ cwd: "/Users/me/dev/website/" })).toBe("website");
  });
  it("uses the worktree leaf name", () => {
    expect(
      project({ cwd: "/Users/me/dev/web/.claude/worktrees/FEAT-1" })
    ).toBe("FEAT-1");
  });
  it("degrades to ? when cwd is missing", () => {
    expect(project({})).toBe("?");
  });
});

describe("trunc", () => {
  it("leaves short text untouched", () => {
    expect(trunc("abc", 5)).toBe("abc");
  });
  it("truncates with an ellipsis at width", () => {
    expect(trunc("abcdef", 4)).toBe("abc…");
  });
});

describe("dwidth", () => {
  it("counts plain ASCII as length", () => {
    expect(dwidth("hello")).toBe(5);
  });
  it("counts group emoji as double width", () => {
    expect(dwidth("⏳")).toBe(2);
    expect(dwidth("🔵")).toBe(2);
    expect(dwidth("💤")).toBe(2);
    expect(dwidth("✅")).toBe(2);
  });
  it("ignores ANSI escape codes", () => {
    expect(dwidth("\x1b[31mred\x1b[0m")).toBe(3);
  });
});

describe("groupSessions", () => {
  it("buckets by group and sorts each newest-first", () => {
    const sessions = [
      { status: "idle", startedAt: 100 },
      { status: "waiting", startedAt: 200 },
      { status: "idle", startedAt: 300 },
      { status: "busy", startedAt: 400 },
      { state: "failed", startedAt: 500 },
    ];
    const b = groupSessions(sessions);
    expect(b.waiting).toHaveLength(1);
    expect(b.busy).toHaveLength(1);
    expect(b.done).toHaveLength(1);
    expect(b.idle.map((s) => s.startedAt)).toEqual([300, 100]); // newest first
  });
});

describe("orderedSessions", () => {
  it("flattens groups in display order: waiting, working, idle, done", () => {
    const sessions = [
      { sessionId: "i", status: "idle", startedAt: 1 },
      { sessionId: "d", state: "done", startedAt: 1 },
      { sessionId: "w", status: "waiting", startedAt: 1 },
      { sessionId: "b", status: "busy", startedAt: 1 },
    ];
    expect(orderedSessions(sessions).map((s) => s.sessionId)).toEqual(["w", "b", "i", "d"]);
  });

  it("matches the row order formatView highlights against", () => {
    const sessions = [
      { sessionId: "a", status: "idle", cwd: "/d/a", startedAt: 300 },
      { sessionId: "b", status: "idle", cwd: "/d/b", startedAt: 100 },
    ];
    // newest-first within idle => a before b
    expect(orderedSessions(sessions).map((s) => s.sessionId)).toEqual(["a", "b"]);
  });
});

describe("sessionKey", () => {
  it("prefers sessionId, then id, then pid", () => {
    expect(sessionKey({ sessionId: "s", id: "i", pid: 1 })).toBe("s");
    expect(sessionKey({ id: "i", pid: 1 })).toBe("i");
    expect(sessionKey({ pid: 42 })).toBe("42");
  });
});

describe("findPaneForPid", () => {
  // session pid 500 -> shell 200 (a pane) two hops up
  const panes = new Map([[200, "%7"], [999, "%1"]]);
  const parents = new Map([[500, 400], [400, 200], [200, 1]]);

  it("walks the parent chain to the hosting pane", () => {
    expect(findPaneForPid(500, panes, parents)).toBe("%7");
  });
  it("matches when the pid is itself a pane shell", () => {
    expect(findPaneForPid(200, panes, parents)).toBe("%7");
  });
  it("returns null when no ancestor is a pane", () => {
    expect(findPaneForPid(500, new Map(), parents)).toBeNull();
    expect(findPaneForPid(12345, panes, new Map())).toBeNull();
  });
});

describe("formatView selection highlight", () => {
  const now = 1_000_000_000_000;
  const sessions = [
    { sessionId: "w", status: "waiting", cwd: "/d/alpha", waitingFor: "x", startedAt: now },
    { sessionId: "i", status: "idle", cwd: "/d/bravo", startedAt: now },
  ];
  it("draws a caret only on the selected row", () => {
    const out = plain(formatView({ sessions, err: null }, 100, now, "12:00:00", 1));
    const caretLines = out.split("\n").filter((l) => l.includes("❯"));
    expect(caretLines).toHaveLength(1);
    expect(caretLines[0]).toContain("bravo"); // index 1 = the idle session
  });
  it("draws no caret when nothing is selected", () => {
    const out = plain(formatView({ sessions, err: null }, 100, now, "12:00:00", -1));
    expect(out).not.toContain("❯");
  });
});

describe("formatView (characterization of current layout)", () => {
  const now = 1_000_000_000_000;
  const cols = 100;
  const view = (data) => plain(formatView(data, cols, now, "12:00:00"));

  it("renders the header with per-group counts and the clock", () => {
    const out = view({
      sessions: [
        { status: "waiting", cwd: "/d/a", waitingFor: "permission prompt", startedAt: now - 60_000 },
        { status: "busy", cwd: "/d/b", startedAt: now - 60_000 },
      ],
      err: null,
    });
    const header = out.split("\n")[0];
    expect(header).toContain("Claude sessions");
    expect(header).toContain("⏳1");
    expect(header).toContain("🔵1");
    expect(header).toContain("12:00:00");
  });

  it("shows the four group titles only when populated, with waiters first", () => {
    const out = view({
      sessions: [
        { status: "idle", cwd: "/d/a", startedAt: now },
        { status: "waiting", cwd: "/d/b", waitingFor: "permission prompt", startedAt: now },
      ],
      err: null,
    });
    expect(out).toContain("WAITING ON YOU (1)");
    expect(out).toContain("IDLE (1)");
    expect(out).not.toContain("WORKING ("); // empty group hidden
    // waiting section appears before idle section
    expect(out.indexOf("WAITING ON YOU")).toBeLessThan(out.indexOf("IDLE"));
  });

  it("shows the waitingFor text for waiters", () => {
    const out = view({
      sessions: [
        { status: "waiting", cwd: "/d/a", waitingFor: "needs your approval", startedAt: now },
      ],
      err: null,
    });
    expect(out).toContain("needs your approval");
  });

  it("shows the state for done rows", () => {
    const out = view({
      sessions: [{ state: "failed", cwd: "/d/a", startedAt: now }],
      err: null,
    });
    expect(out).toContain("DONE (1)");
    expect(out).toContain("failed");
  });

  it("handles the empty case", () => {
    const out = view({ sessions: [], err: null });
    expect(out).toContain("(no Claude sessions detected)");
  });

  it("surfaces an error", () => {
    const out = view({ sessions: [], err: "malformed JSON from claude agents" });
    expect(out).toContain("malformed JSON from claude agents");
  });

  it("never emits a line wider than the terminal", () => {
    const sessions = Array.from({ length: 6 }, (_, i) => ({
      status: "waiting",
      cwd: `/Users/me/dev/some-really-long-project-name-${i}`,
      waitingFor: "a very long waiting-for message that would overflow the row badly",
      startedAt: now - i * 86_400_000,
    }));
    for (const line of plain(formatView({ sessions, err: null }, 80, now, "12:00:00")).split("\n")) {
      expect(dwidth(line)).toBeLessThanOrEqual(80);
    }
  });
});
