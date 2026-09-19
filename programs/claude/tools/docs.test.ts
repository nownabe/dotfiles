import { describe, it } from "@std/testing/bdd";
import { expect } from "@std/expect";
import { listDocs, renderIndex, resolveDoc, summarize } from "./docs.ts";

describe("summarize", () => {
  it("returns the first sentence of the first paragraph after the title", () => {
    const markdown =
      "# `gh get-release`\n\nGet release information. Pipe through `jq`.\n\n## Usage\n";
    expect(summarize(markdown)).toBe("Get release information.");
  });

  it("joins a paragraph that wraps across lines", () => {
    const markdown = "# Title\n\nA hook that blocks\ncalls matching a pattern.\n";
    expect(summarize(markdown)).toBe("A hook that blocks calls matching a pattern.");
  });
});

describe("resolveDoc", () => {
  const names = ["claude-hooks/pre-bash", "claude-tools/gh/get-release", "claude-tools/docs"];

  it("accepts a full name, a trailing segment, and stray slashes or .md", () => {
    expect(resolveDoc(names, "claude-tools/gh/get-release")).toEqual({
      kind: "found",
      name: "claude-tools/gh/get-release",
    });
    expect(resolveDoc(names, "get-release")).toEqual({
      kind: "found",
      name: "claude-tools/gh/get-release",
    });
    expect(resolveDoc(names, "/gh/get-release.md")).toEqual({
      kind: "found",
      name: "claude-tools/gh/get-release",
    });
  });

  it("does not match inside a segment", () => {
    expect(resolveDoc(names, "release")).toEqual({ kind: "missing" });
  });

  it("reports ambiguity", () => {
    const dup = [...names, "other/gh/get-release"];
    expect(resolveDoc(dup, "gh/get-release")).toEqual({
      kind: "ambiguous",
      candidates: ["claude-tools/gh/get-release", "other/gh/get-release"],
    });
  });
});

describe("docs directory", () => {
  it("indexes every doc with a one-line summary", async () => {
    const names = await listDocs();
    expect(names).toContain("claude-tools/docs");
    expect(names).toContain("claude-tools/gh/get-release");
    expect(names).toContain("claude-hooks/pre-bash");

    const index = await renderIndex();
    for (const name of names) {
      const row = index.split("\n").find((line) => line.startsWith(`${name} `));
      expect(row, name).toBeDefined();
      expect(row!.slice(name.length).trim(), name).not.toBe("");
    }
  });
});
