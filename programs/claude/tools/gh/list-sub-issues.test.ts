import { describe, it } from "@std/testing/bdd";
import { expect } from "@std/expect";
import { listSubIssues } from "./list-sub-issues.ts";
import { createMockRunner, stubExit } from "./testing.ts";

describe("listSubIssues", () => {
  it("should call gh api with correct endpoint and output result", async () => {
    const subIssuesJson = JSON.stringify([
      { id: 1, number: 10, title: "Sub-issue 1" },
      { id: 2, number: 11, title: "Sub-issue 2" },
    ]);
    const { fn, calls } = createMockRunner([{ stdout: subIssuesJson, stderr: "", exitCode: 0 }]);

    await listSubIssues({ owner: "myorg", repo: "myrepo", issueNumber: 5 }, fn);

    expect(calls).toHaveLength(1);
    expect(calls[0]).toEqual(["api", "repos/myorg/myrepo/issues/5/sub_issues"]);
  });

  it("should exit with error when API call fails", async () => {
    const { fn } = createMockRunner([{ stdout: "", stderr: "Not Found", exitCode: 1 }]);
    const exit = stubExit();

    try {
      await listSubIssues({ owner: "myorg", repo: "myrepo", issueNumber: 999 }, fn);
    } catch {
      // expected
    } finally {
      exit.restore();
    }

    expect(exit.codes).toEqual([1]);
  });
});
