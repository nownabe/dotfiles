import { describe, it } from "@std/testing/bdd";
import { expect, fn as mockFn } from "@std/expect";
import { getJobLogs } from "./get-job-logs.ts";
import { createMockRunner, stubExit } from "./testing.ts";

describe("getJobLogs", () => {
  it("should call gh api with correct endpoint", async () => {
    const logs = "Some log output";
    const { fn, calls } = createMockRunner([{ stdout: logs, stderr: "", exitCode: 0 }]);

    await getJobLogs({ owner: "myorg", repo: "myrepo", jobId: "12345" }, fn);

    expect(calls).toHaveLength(1);
    expect(calls[0]).toEqual(["api", "repos/myorg/myrepo/actions/jobs/12345/logs"]);
  });

  it("should strip timestamps by default", async () => {
    const logs = "2025-03-06T10:30:45.1234567Z Step 1\n2025-03-06T10:30:46.9876543Z Step 2\n";
    const { fn } = createMockRunner([{ stdout: logs, stderr: "", exitCode: 0 }]);

    const logSpy = mockFn() as typeof console.log;
    const originalLog = console.log;
    console.log = logSpy;

    await getJobLogs({ owner: "myorg", repo: "myrepo", jobId: "12345" }, fn);

    console.log = originalLog;
    expect(logSpy).toHaveBeenCalledWith("Step 1\nStep 2\n");
  });

  it("should preserve timestamps when stripTimestamps is false", async () => {
    const logs = "2025-03-06T10:30:45.1234567Z Step 1\n2025-03-06T10:30:46.9876543Z Step 2\n";
    const { fn } = createMockRunner([{ stdout: logs, stderr: "", exitCode: 0 }]);

    const logSpy = mockFn() as typeof console.log;
    const originalLog = console.log;
    console.log = logSpy;

    await getJobLogs(
      { owner: "myorg", repo: "myrepo", jobId: "12345", stripTimestamps: false },
      fn,
    );

    console.log = originalLog;
    expect(logSpy).toHaveBeenCalledWith(logs);
  });

  it("should exit with error when API call fails", async () => {
    const { fn } = createMockRunner([{ stdout: "", stderr: "Not Found", exitCode: 1 }]);
    const exit = stubExit();

    try {
      await getJobLogs({ owner: "myorg", repo: "myrepo", jobId: "99999" }, fn);
    } catch {
      // expected
    } finally {
      exit.restore();
    }

    expect(exit.codes).toEqual([1]);
  });
});
