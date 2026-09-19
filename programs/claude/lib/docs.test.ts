import { describe, it } from "@std/testing/bdd";
import { expect } from "@std/expect";
import { DOCS_ROOT, listDocs, renderIndex, resolveDoc, summarize } from "./docs.ts";

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
  const names = ["docs", "gh/get-release", "gh/get-pr-reviews"];

  it("accepts a full name, a trailing segment, and stray slashes or .md", () => {
    expect(resolveDoc(names, "gh/get-release")).toEqual({ kind: "found", name: "gh/get-release" });
    expect(resolveDoc(names, "get-release")).toEqual({ kind: "found", name: "gh/get-release" });
    expect(resolveDoc(names, "/gh/get-release.md")).toEqual({
      kind: "found",
      name: "gh/get-release",
    });
  });

  it("does not match inside a segment", () => {
    expect(resolveDoc(names, "release")).toEqual({ kind: "missing" });
  });

  it("reports ambiguity", () => {
    const dup = [...names, "other/get-release"];
    expect(resolveDoc(dup, "get-release")).toEqual({
      kind: "ambiguous",
      candidates: ["gh/get-release", "other/get-release"],
    });
  });
});

describe("docs directories", () => {
  for (
    const [cli, expected] of [
      ["claude-tools", ["docs", "gh/get-release"]],
      ["claude-hooks", ["docs", "pre-bash"]],
    ] as const
  ) {
    it(`indexes every ${cli} doc with a one-line summary`, async () => {
      const dir = new URL(`${cli}/`, DOCS_ROOT);
      const names = await listDocs(dir);
      for (const name of expected) expect(names).toContain(name);

      const index = await renderIndex(cli, dir);
      expect(index).toContain(`\`${cli} docs <name>\``);
      for (const name of names) {
        const row = index.split("\n").find((line) => line.startsWith(`${name} `));
        expect(row, name).toBeDefined();
        expect(row!.slice(name.length).trim(), name).not.toBe("");
      }
    });
  }
});
