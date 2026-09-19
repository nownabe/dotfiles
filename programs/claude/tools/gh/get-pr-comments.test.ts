import { describe, it } from "@std/testing/bdd";
import { expect } from "@std/expect";
import { getPrComments } from "./get-pr-comments.ts";
import { createMockRunner, stubExit } from "./testing.ts";

describe("getPrComments", () => {
  it("should get comments for a pull request", async () => {
    const comments = [
      { id: 1, body: "Looks good!", user: { login: "reviewer" } },
      { id: 2, body: "Please fix this", user: { login: "maintainer" } },
    ];
    const { fn, calls } = createMockRunner([
      { stdout: JSON.stringify(comments), stderr: "", exitCode: 0 },
    ]);

    const result = await getPrComments({ owner: "myorg", repo: "myrepo", prNumber: 42 }, fn);

    expect(result).toBe(JSON.stringify(comments));
    expect(calls).toHaveLength(1);
    expect(calls[0]).toEqual(["api", "repos/myorg/myrepo/pulls/42/comments"]);
  });

  it("should exit with error when the API call fails", async () => {
    const { fn } = createMockRunner([{ stdout: "", stderr: "Not Found", exitCode: 1 }]);
    const exit = stubExit();

    try {
      await getPrComments({ owner: "owner", repo: "repo", prNumber: 99 }, fn);
    } catch {
      // expected
    } finally {
      exit.restore();
    }

    expect(exit.codes).toEqual([1]);
  });
});
