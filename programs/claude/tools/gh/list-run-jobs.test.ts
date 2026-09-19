import { describe, it } from "@std/testing/bdd";
import { expect } from "@std/expect";
import { listRunJobs } from "./list-run-jobs.ts";
import { createMockRunner, stubExit } from "./testing.ts";

describe("listRunJobs", () => {
  it("should call gh api with correct endpoint and jq expression", async () => {
    const jobsJson = JSON.stringify([
      {
        name: "Build",
        conclusion: "success",
        id: 1,
        url: "https://github.com/myorg/myrepo/actions/runs/12345/job/1",
        steps: [{ name: "Checkout", conclusion: "success" }],
      },
    ]);
    const { fn, calls } = createMockRunner([{ stdout: jobsJson, stderr: "", exitCode: 0 }]);

    await listRunJobs({ owner: "myorg", repo: "myrepo", runId: "12345" }, fn);

    expect(calls).toHaveLength(1);
    expect(calls[0]).toEqual([
      "api",
      "repos/myorg/myrepo/actions/runs/12345/jobs",
      "--jq",
      "[.jobs[] | {name, conclusion, id, url: .html_url, steps: [.steps[] | {name, conclusion}]}]",
    ]);
  });

  it("should exit with error when API call fails", async () => {
    const { fn } = createMockRunner([{ stdout: "", stderr: "Not Found", exitCode: 1 }]);
    const exit = stubExit();

    try {
      await listRunJobs({ owner: "myorg", repo: "myrepo", runId: "99999" }, fn);
    } catch {
      // expected
    } finally {
      exit.restore();
    }

    expect(exit.codes).toEqual([1]);
  });
});
