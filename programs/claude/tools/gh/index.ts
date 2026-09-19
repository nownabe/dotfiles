// Imported statically, not lazily: `deno check --no-remote` only walks static
// imports, and that check is what keeps these commands runnable offline.
import { main as addSubIssues } from "./add-sub-issues.ts";
import { main as getActionsRun } from "./get-actions-run.ts";
import { main as getJobLogs } from "./get-job-logs.ts";
import { main as getPrComments } from "./get-pr-comments.ts";
import { main as getPrReviews } from "./get-pr-reviews.ts";
import { main as getRelease } from "./get-release.ts";
import { main as getRepoContent } from "./get-repo-content.ts";
import { main as listRunJobs } from "./list-run-jobs.ts";
import { main as listSubIssues } from "./list-sub-issues.ts";
import { main as resolveTagSha } from "./resolve-tag-sha.ts";

export const commands: Record<string, () => Promise<void>> = {
  "add-sub-issues": addSubIssues,
  "get-actions-run": getActionsRun,
  "get-job-logs": getJobLogs,
  "get-pr-comments": getPrComments,
  "get-pr-reviews": getPrReviews,
  "get-release": getRelease,
  "get-repo-content": getRepoContent,
  "list-run-jobs": listRunJobs,
  "list-sub-issues": listSubIssues,
  "resolve-tag-sha": resolveTagSha,
};
