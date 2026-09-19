// Lazily imported so that adding commands does not slow down every invocation:
// only the command actually being run is loaded.
export const commands: Record<string, () => Promise<void>> = {
  "add-sub-issues": () => import("./add-sub-issues.ts").then((m) => m.main()),
  "get-actions-run": () => import("./get-actions-run.ts").then((m) => m.main()),
  "get-job-logs": () => import("./get-job-logs.ts").then((m) => m.main()),
  "get-pr-comments": () => import("./get-pr-comments.ts").then((m) => m.main()),
  "get-pr-reviews": () => import("./get-pr-reviews.ts").then((m) => m.main()),
  "get-release": () => import("./get-release.ts").then((m) => m.main()),
  "get-repo-content": () => import("./get-repo-content.ts").then((m) => m.main()),
  "list-run-jobs": () => import("./list-run-jobs.ts").then((m) => m.main()),
  "list-sub-issues": () => import("./list-sub-issues.ts").then((m) => m.main()),
  "resolve-tag-sha": () => import("./resolve-tag-sha.ts").then((m) => m.main()),
};
