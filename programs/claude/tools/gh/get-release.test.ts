import { describe, it } from "@std/testing/bdd";
import { expect } from "@std/expect";
import { getRelease } from "./get-release.ts";
import { createMockRunner, stubExit } from "./testing.ts";

describe("getRelease", () => {
  it("should get the latest release", async () => {
    const { fn, calls } = createMockRunner([
      {
        stdout: JSON.stringify({ tag_name: "v1.0.0", name: "Release 1.0.0" }),
        stderr: "",
        exitCode: 0,
      },
    ]);

    const result = await getRelease({ repo: "owner/repo" }, fn);

    expect(result).toBe(JSON.stringify({ tag_name: "v1.0.0", name: "Release 1.0.0" }));
    expect(calls).toHaveLength(1);
    expect(calls[0]).toEqual(["api", "repos/owner/repo/releases/latest"]);
  });

  it("should get a release by tag", async () => {
    const { fn, calls } = createMockRunner([
      {
        stdout: JSON.stringify({ tag_name: "v2.0.0", body: "Release notes" }),
        stderr: "",
        exitCode: 0,
      },
    ]);

    const result = await getRelease({ repo: "myorg/myrepo", tag: "v2.0.0" }, fn);

    expect(result).toBe(JSON.stringify({ tag_name: "v2.0.0", body: "Release notes" }));
    expect(calls).toHaveLength(1);
    expect(calls[0]).toEqual(["api", "repos/myorg/myrepo/releases/tags/v2.0.0"]);
  });

  it("should exit with error when the API call fails", async () => {
    const { fn } = createMockRunner([{ stdout: "", stderr: "Not Found", exitCode: 1 }]);
    const exit = stubExit();

    try {
      await getRelease({ repo: "owner/repo" }, fn);
    } catch {
      // expected
    } finally {
      exit.restore();
    }

    expect(exit.codes).toEqual([1]);
  });
});
