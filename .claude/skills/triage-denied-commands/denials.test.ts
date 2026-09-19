// deno test --allow-read --allow-write denials.test.ts

import assert from "node:assert/strict";
import { join } from "node:path";
import { extractDenials, readAllDenials } from "./denials.ts";

function toolUse(id: string, name: string, input: unknown): string {
  return JSON.stringify({
    type: "assistant",
    message: { content: [{ type: "tool_use", id, name, input }] },
  });
}

function denial(
  id: string,
  kind: string,
  timestamp: string,
  result: unknown,
): string {
  return JSON.stringify({
    type: "user",
    timestamp,
    sessionId: "session-1",
    cwd: "/work",
    toolDenialKind: kind,
    toolUseResult: result,
    message: {
      content: [{ type: "tool_result", tool_use_id: id, is_error: true }],
    },
  });
}

Deno.test("extractDenials pairs each denial with the command it answered", () => {
  const lines = [
    toolUse("a", "Bash", { command: "rm -rf build" }),
    toolUse("b", "Bash", { command: "ls" }),
    JSON.stringify({
      type: "user",
      message: {
        content: [{ type: "tool_result", tool_use_id: "b", content: "ok" }],
      },
    }),
    denial(
      "a",
      "permission-rule",
      "2026-09-19T13:38:56.158Z",
      "Error: `rm` is forbidden.",
    ),
  ];

  assert.deepEqual(extractDenials(lines), [
    {
      timestamp: "2026-09-19T13:38:56.158Z",
      sessionId: "session-1",
      cwd: "/work",
      kind: "permission-rule",
      tool: "Bash",
      command: "rm -rf build",
      reason: "`rm` is forbidden.",
    },
  ]);
});

Deno.test("extractDenials describes non-Bash tools by their target and skips AskUserQuestion", () => {
  const lines = [
    toolUse("w", "Write", { file_path: "/etc/hosts", content: "x" }),
    denial("w", "automode-blocked", "2026-09-19T13:40:00.000Z", {
      error: "blocked",
    }),
    toolUse("q", "AskUserQuestion", { questions: [] }),
    denial("q", "user-rejected", "2026-09-19T13:41:00.000Z", "User rejected"),
  ];

  assert.deepEqual(
    extractDenials(lines).map((d) => [d.tool, d.command, d.reason]),
    [["Write", "/etc/hosts", '{"error":"blocked"}']],
  );
});

Deno.test("extractDenials ignores malformed lines and results without a denial", () => {
  const lines = [
    "",
    "not json",
    "null",
    "42",
    toolUse("a", "Bash", { command: "ls" }),
  ];

  assert.deepEqual(extractDenials(lines), []);
});

Deno.test("readAllDenials collects every transcript under the dir, oldest first", async () => {
  const dir = Deno.makeTempDirSync({ prefix: "denials-test-" });
  try {
    Deno.mkdirSync(join(dir, "p1", "nested"), { recursive: true });
    Deno.mkdirSync(join(dir, "p2"));
    Deno.writeTextFileSync(
      join(dir, "p1", "nested", "s.jsonl"),
      [
        toolUse("a", "Bash", { command: "later" }),
        denial("a", "permission-rule", "2026-09-19T13:40:00.000Z", "no"),
      ].join("\n"),
    );
    Deno.writeTextFileSync(
      join(dir, "p2", "s.jsonl"),
      [
        toolUse("b", "Bash", { command: "earlier" }),
        denial("b", "permission-rule", "2026-09-19T13:30:00.000Z", "no"),
      ].join("\n"),
    );
    Deno.writeTextFileSync(join(dir, "p2", "notes.md"), "not a transcript");

    const commands = (await readAllDenials(dir)).map((d) => d.command);

    assert.deepEqual(commands, ["earlier", "later"]);
  } finally {
    Deno.removeSync(dir, { recursive: true });
  }
});
