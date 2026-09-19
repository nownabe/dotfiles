import { afterEach, beforeEach, describe, it as test } from "@std/testing/bdd";
import { expect } from "@std/expect";
import { join } from "node:path";
import { checkForbiddenPatterns, extractContent, loadForbiddenPatterns } from "./pre-write.ts";
import type { ActivePattern } from "./pre-bash.ts";

// Assembled at runtime: a real session URL must never sit in a file on disk,
// which is the very thing this hook exists to prevent.
const SESSION_URL = "https://claude.ai/code/" + "session_" + "01NA2bKFq71UFh4c9j3kD4XC";

const ATTRIBUTION: ActivePattern[] = [{
  pattern: "claude\\.ai/(?:code/)?session_[A-Za-z0-9]|Claude-Session:",
  type: "regex",
  reason: "forbidden",
  suggestion: "remove it",
}];

describe("extractContent", () => {
  test("reads Write content", () => {
    expect(extractContent({ content: "hello" })).toEqual(["hello"]);
  });

  test("reads Edit new_string", () => {
    expect(extractContent({ new_string: "hello" })).toEqual(["hello"]);
  });

  test("reads NotebookEdit new_source", () => {
    expect(extractContent({ new_source: "hello" })).toEqual(["hello"]);
  });

  test("ignores empty and missing fields", () => {
    expect(extractContent({ file_path: "/tmp/a", content: "" })).toEqual([]);
  });
});

describe("checkForbiddenPatterns", () => {
  test("denies a session URL anywhere in the content", () => {
    const body = `## Summary\n\n- did a thing\n\n${SESSION_URL}\n`;
    expect(checkForbiddenPatterns([body], ATTRIBUTION)).toEqual([
      { reason: "forbidden", suggestion: "remove it" },
    ]);
  });

  test("denies a Claude-Session trailer", () => {
    expect(checkForbiddenPatterns(["fix: x\n\nClaude-Session: redacted"], ATTRIBUTION)).not
      .toBeNull();
  });

  test("allows content that merely names the pattern without an id", () => {
    expect(checkForbiddenPatterns(["never write claude.ai/code/session URLs"], ATTRIBUTION))
      .toBeNull();
  });

  test("allows ordinary content", () => {
    expect(checkForbiddenPatterns(["## Summary\n\n- did a thing\n"], ATTRIBUTION)).toBeNull();
  });

  test("returns null when no patterns are configured", () => {
    expect(checkForbiddenPatterns([SESSION_URL], [])).toBeNull();
  });
});

describe("loadForbiddenPatterns", () => {
  let dir: string;
  let originalHome: string | undefined;

  beforeEach(() => {
    dir = Deno.makeTempDirSync();
    originalHome = Deno.env.get("HOME");
    Deno.env.set("HOME", dir);
    Deno.mkdirSync(join(dir, ".claude"), { recursive: true });
  });

  afterEach(() => {
    if (originalHome === undefined) Deno.env.delete("HOME");
    else Deno.env.set("HOME", originalHome);
    Deno.removeSync(dir, { recursive: true });
  });

  function writeConfig(config: unknown) {
    Deno.writeTextFileSync(
      join(dir, ".claude", "nownabe-claude-hooks.json"),
      JSON.stringify(config),
    );
  }

  test("reads preWrite.forbiddenPatterns", () => {
    writeConfig({
      preWrite: { forbiddenPatterns: { "foo": { reason: "r", suggestion: "s" } } },
    });
    expect(loadForbiddenPatterns(dir)).toEqual([
      { pattern: "foo", reason: "r", suggestion: "s", type: undefined, multiline: undefined },
    ]);
  });

  test("skips disabled entries", () => {
    writeConfig({
      preWrite: { forbiddenPatterns: { "foo": { disabled: true } } },
    });
    expect(loadForbiddenPatterns(dir)).toEqual([]);
  });

  test("ignores preBash patterns", () => {
    writeConfig({
      preBash: { forbiddenPatterns: { "^echo\\b": { reason: "r", suggestion: "s" } } },
    });
    expect(loadForbiddenPatterns(dir)).toEqual([]);
  });
});
