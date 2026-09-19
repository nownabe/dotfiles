import { describe, it } from "@std/testing/bdd";
import { expect } from "@std/expect";
import { join } from "node:path";
import { extractDenials, readAllDenials } from "./list-denials.ts";

function toolUse(id: string, name: string, input: unknown): string {
  return JSON.stringify({
    type: "assistant",
    message: { content: [{ type: "tool_use", id, name, input }] },
  });
}

function denial(id: string, kind: string, timestamp: string, result: unknown): string {
  return JSON.stringify({
    type: "user",
    timestamp,
    sessionId: "session-1",
    cwd: "/work",
    toolDenialKind: kind,
    toolUseResult: result,
    message: { content: [{ type: "tool_result", tool_use_id: id, is_error: true }] },
  });
}

describe("extractDenials", () => {
  it("pairs each denial with the command it answered", () => {
    const lines = [
      toolUse("a", "Bash", { command: "rm -rf build" }),
      toolUse("b", "Bash", { command: "ls" }),
      JSON.stringify({
        type: "user",
        message: { content: [{ type: "tool_result", tool_use_id: "b", content: "ok" }] },
      }),
      denial("a", "permission-rule", "2026-09-19T13:38:56.158Z", "Error: `rm` is forbidden."),
    ];

    expect(extractDenials(lines)).toEqual([
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

  it("describes non-Bash tools by their target and skips AskUserQuestion", () => {
    const lines = [
      toolUse("w", "Write", { file_path: "/etc/hosts", content: "x" }),
      denial("w", "automode-blocked", "2026-09-19T13:40:00.000Z", { error: "blocked" }),
      toolUse("q", "AskUserQuestion", { questions: [] }),
      denial("q", "user-rejected", "2026-09-19T13:41:00.000Z", "User rejected"),
    ];

    expect(extractDenials(lines).map((d) => [d.tool, d.command, d.reason])).toEqual([
      ["Write", "/etc/hosts", '{"error":"blocked"}'],
    ]);
  });

  it("ignores malformed lines and results without a denial", () => {
    const lines = ["", "not json", "null", "42", toolUse("a", "Bash", { command: "ls" })];

    expect(extractDenials(lines)).toEqual([]);
  });
});

describe("readAllDenials", () => {
  it("collects every transcript under the projects dir, oldest first", async () => {
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

      expect(commands).toEqual(["earlier", "later"]);
    } finally {
      Deno.removeSync(dir, { recursive: true });
    }
  });
});
