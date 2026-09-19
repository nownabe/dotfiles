import { describe, it } from "@std/testing/bdd";
import { expect } from "@std/expect";
import { getActionsRun } from "./get-actions-run.ts";
import { createMockRunner, stubExit } from "./testing.ts";

describe("getActionsRun", () => {
  it("should call gh api with correct endpoint and output result", async () => {
    const runJson = JSON.stringify({
      id: 12345,
      status: "completed",
      conclusion: "success",
    });
    const { fn, calls } = createMockRunner([{ stdout: runJson, stderr: "", exitCode: 0 }]);

    await getActionsRun({ owner: "myorg", repo: "myrepo", runId: "12345" }, fn);

    expect(calls).toHaveLength(1);
    expect(calls[0]).toEqual(["api", "repos/myorg/myrepo/actions/runs/12345"]);
  });

  it("should exit with error when API call fails", async () => {
    const { fn } = createMockRunner([{ stdout: "", stderr: "Not Found", exitCode: 1 }]);
    const exit = stubExit();

    try {
      await getActionsRun({ owner: "myorg", repo: "myrepo", runId: "99999" }, fn);
    } catch {
      // expected
    } finally {
      exit.restore();
    }

    expect(exit.codes).toEqual([1]);
  });
});
