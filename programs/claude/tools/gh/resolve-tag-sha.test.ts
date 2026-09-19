import { describe, it } from "@std/testing/bdd";
import { expect } from "@std/expect";
import { resolveTagSha } from "./resolve-tag-sha.ts";
import { createMockRunner, stubExit } from "./testing.ts";

describe("resolveTagSha", () => {
  it("should resolve a lightweight tag directly", async () => {
    const { fn, calls } = createMockRunner([
      {
        stdout: JSON.stringify({ type: "commit", sha: "abc123def456" }),
        stderr: "",
        exitCode: 0,
      },
    ]);

    const sha = await resolveTagSha({ repo: "actions/setup-node", tag: "v4.4.0" }, fn);

    expect(sha).toBe("abc123def456");
    expect(calls).toHaveLength(1);
    expect(calls[0]).toEqual([
      "api",
      "repos/actions/setup-node/git/ref/tags/v4.4.0",
      "--jq",
      ".object",
    ]);
  });

  it("should dereference an annotated tag to get the commit SHA", async () => {
    const { fn, calls } = createMockRunner([
      {
        stdout: JSON.stringify({ type: "tag", sha: "tag-object-sha" }),
        stderr: "",
        exitCode: 0,
      },
      {
        stdout: "commit-sha-from-annotated-tag",
        stderr: "",
        exitCode: 0,
      },
    ]);

    const sha = await resolveTagSha({ repo: "dorny/paths-filter", tag: "v3.0.2" }, fn);

    expect(sha).toBe("commit-sha-from-annotated-tag");
    expect(calls).toHaveLength(2);
    expect(calls[0]).toEqual([
      "api",
      "repos/dorny/paths-filter/git/ref/tags/v3.0.2",
      "--jq",
      ".object",
    ]);
    expect(calls[1]).toEqual([
      "api",
      "repos/dorny/paths-filter/git/tags/tag-object-sha",
      "--jq",
      ".object.sha",
    ]);
  });

  it("should exit with error when the ref API call fails", async () => {
    const { fn } = createMockRunner([{ stdout: "", stderr: "Not Found", exitCode: 1 }]);
    const exit = stubExit();

    try {
      await resolveTagSha({ repo: "actions/setup-node", tag: "nonexistent" }, fn);
    } catch {
      // expected
    } finally {
      exit.restore();
    }

    expect(exit.codes).toEqual([1]);
  });

  it("should exit with error when dereferencing an annotated tag fails", async () => {
    const { fn } = createMockRunner([
      {
        stdout: JSON.stringify({ type: "tag", sha: "tag-object-sha" }),
        stderr: "",
        exitCode: 0,
      },
      { stdout: "", stderr: "Internal Server Error", exitCode: 1 },
    ]);
    const exit = stubExit();

    try {
      await resolveTagSha({ repo: "dorny/paths-filter", tag: "v3.0.2" }, fn);
    } catch {
      // expected
    } finally {
      exit.restore();
    }

    expect(exit.codes).toEqual([1]);
  });

  it("should exit with error for unexpected object type", async () => {
    const { fn } = createMockRunner([
      {
        stdout: JSON.stringify({ type: "blob", sha: "some-sha" }),
        stderr: "",
        exitCode: 0,
      },
    ]);
    const exit = stubExit();

    try {
      await resolveTagSha({ repo: "some/repo", tag: "v1.0.0" }, fn);
    } catch {
      // expected
    } finally {
      exit.restore();
    }

    expect(exit.codes).toEqual([1]);
  });
});
