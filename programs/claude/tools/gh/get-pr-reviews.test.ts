import { describe, it } from "@std/testing/bdd";
import { expect } from "@std/expect";
import { getPrReviews } from "./get-pr-reviews.ts";
import { createMockRunner, stubExit } from "./testing.ts";

describe("getPrReviews", () => {
  it("should call gh api with correct endpoint and output result", async () => {
    const reviewsJson = JSON.stringify([
      { id: 1, user: { login: "reviewer1" }, state: "APPROVED", body: "LGTM" },
      { id: 2, user: { login: "reviewer2" }, state: "CHANGES_REQUESTED", body: "Please fix" },
    ]);
    const { fn, calls } = createMockRunner([{ stdout: reviewsJson, stderr: "", exitCode: 0 }]);

    await getPrReviews({ owner: "myorg", repo: "myrepo", pullNumber: 26 }, fn);

    expect(calls).toHaveLength(1);
    expect(calls[0]).toEqual(["api", "repos/myorg/myrepo/pulls/26/reviews"]);
  });

  it("should exit with error when API call fails", async () => {
    const { fn } = createMockRunner([{ stdout: "", stderr: "Not Found", exitCode: 1 }]);
    const exit = stubExit();

    try {
      await getPrReviews({ owner: "myorg", repo: "myrepo", pullNumber: 999 }, fn);
    } catch {
      // expected
    } finally {
      exit.restore();
    }

    expect(exit.codes).toEqual([1]);
  });
});
