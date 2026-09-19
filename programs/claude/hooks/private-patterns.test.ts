import { afterEach, beforeEach, describe, it as test } from "@std/testing/bdd";
import { expect } from "@std/expect";
import { join } from "node:path";
import {
  findPrivateMatches,
  isPrivateRemote,
  loadPrivatePatterns,
  parsePatternFile,
  PATTERNS_FILE,
  REMOTES_FILE,
} from "./private-patterns.ts";

// Placeholder values only (RFC 2606 / 5737): this test file is committed.
const HOST = "git\\.example\\.invalid";
const PORT = ":1234";

describe("parsePatternFile", () => {
  test("drops comments, blanks and surrounding whitespace", () => {
    expect(parsePatternFile(`# c\n\n  ${HOST}  \n${PORT}\n`)).toEqual([HOST, PORT]);
  });
});

describe("isPrivateRemote", () => {
  test("matches case-insensitively", () => {
    expect(isPrivateRemote("git@GitHub.com:owner/Private.git", ["github\\.com[:/]owner/private"]))
      .toBe(true);
  });

  test("does not match an unrelated remote", () => {
    expect(isPrivateRemote("git@github.com:owner/public.git", ["github\\.com[:/]owner/private"]))
      .toBe(false);
  });
});

describe("findPrivateMatches", () => {
  test("reports each pattern that hits any text", () => {
    const hits = findPrivateMatches(["clean", "ssh://git.example.invalid:1234/x"], [HOST, PORT]);
    expect(hits?.map((h) => h.reason)).toEqual([
      expect.stringContaining(HOST),
      expect.stringContaining(PORT),
    ]);
  });

  test("returns null when nothing matches", () => {
    expect(findPrivateMatches(["## Summary\n\n- x"], [HOST])).toBeNull();
  });

  test("returns null with no patterns", () => {
    expect(findPrivateMatches(["git.example.invalid"], [])).toBeNull();
  });
});

describe("loadPrivatePatterns", () => {
  let dir: string;
  let originalXdg: string | undefined;

  beforeEach(() => {
    dir = Deno.makeTempDirSync();
    originalXdg = Deno.env.get("XDG_CONFIG_HOME");
    Deno.env.set("XDG_CONFIG_HOME", dir);
    Deno.mkdirSync(join(dir, "git"), { recursive: true });
  });

  afterEach(() => {
    if (originalXdg === undefined) Deno.env.delete("XDG_CONFIG_HOME");
    else Deno.env.set("XDG_CONFIG_HOME", originalXdg);
    Deno.removeSync(dir, { recursive: true });
  });

  function write(name: string, text: string) {
    Deno.writeTextFileSync(join(dir, "git", name), text);
  }

  test("is empty when no pattern file exists", () => {
    expect(loadPrivatePatterns("/repo", () => "git@github.com:o/public.git")).toEqual([]);
  });

  test("is empty when the file holds only comments", () => {
    write(PATTERNS_FILE, "# nothing yet\n");
    expect(loadPrivatePatterns("/repo", () => "git@github.com:o/public.git")).toEqual([]);
  });

  test("returns the patterns for a public remote", () => {
    write(PATTERNS_FILE, `${HOST}\n`);
    write(REMOTES_FILE, "github\\.com[:/]o/private\n");
    expect(loadPrivatePatterns("/repo", () => "git@github.com:o/public.git")).toEqual([HOST]);
  });

  test("is empty for a private remote", () => {
    write(PATTERNS_FILE, `${HOST}\n`);
    write(REMOTES_FILE, "github\\.com[:/]o/private\n");
    expect(loadPrivatePatterns("/repo", () => "git@github.com:o/private.git")).toEqual([]);
  });

  test("treats a directory with no remote as public", () => {
    write(PATTERNS_FILE, `${HOST}\n`);
    write(REMOTES_FILE, "github\\.com[:/]o/private\n");
    expect(loadPrivatePatterns("/tmp/scratch", () => null)).toEqual([HOST]);
  });

  test("does not ask for the remote when no remotes are configured", () => {
    write(PATTERNS_FILE, `${HOST}\n`);
    let asked = false;
    expect(loadPrivatePatterns("/repo", () => {
      asked = true;
      return null;
    })).toEqual([HOST]);
    expect(asked).toBe(false);
  });
});
