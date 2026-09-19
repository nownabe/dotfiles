import { parseRepoFlag, resolveRepo, type RunCommandFn, runGh } from "./repo.ts";

export interface GetPrReviewsOptions {
  owner: string;
  repo: string;
  pullNumber: number;
}

export async function getPrReviews(
  options: GetPrReviewsOptions,
  runCommand: RunCommandFn = runGh,
): Promise<void> {
  const { owner, repo, pullNumber } = options;

  const result = await runCommand(["api", `repos/${owner}/${repo}/pulls/${pullNumber}/reviews`]);

  if (result.exitCode !== 0) {
    console.error(`Failed to get reviews for PR #${pullNumber}: ${result.stderr}`);
    Deno.exit(1);
  }

  console.log(result.stdout);
}

export async function main(): Promise<void> {
  const { remaining: allArgs, owner: flagOwner, repo: flagRepo } = parseRepoFlag(Deno.args);
  const remaining = allArgs.slice(2);

  if (remaining.length < 1) {
    console.error("Usage: claude-tools gh get-pr-reviews <pull_number> [--repo <owner/repo>]");
    Deno.exit(1);
  }

  const pullNumber = Number(remaining[0]);

  if (Number.isNaN(pullNumber)) {
    console.error("Pull request number must be a valid integer");
    Deno.exit(1);
  }

  let owner: string;
  let repo: string;
  if (flagOwner && flagRepo) {
    owner = flagOwner;
    repo = flagRepo;
  } else {
    const resolved = await resolveRepo();
    owner = resolved.owner;
    repo = resolved.repo;
  }

  await getPrReviews({ owner, repo, pullNumber });
}
