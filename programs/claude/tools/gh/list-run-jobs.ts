import { parseRepoFlag, resolveRepo, type RunCommandFn, runGh } from "./repo.ts";

export interface ListRunJobsOptions {
  owner: string;
  repo: string;
  runId: string;
}

export async function listRunJobs(
  options: ListRunJobsOptions,
  runCommand: RunCommandFn = runGh,
): Promise<void> {
  const { owner, repo, runId } = options;

  const result = await runCommand([
    "api",
    `repos/${owner}/${repo}/actions/runs/${runId}/jobs`,
    "--jq",
    "[.jobs[] | {name, conclusion, id, url: .html_url, steps: [.steps[] | {name, conclusion}]}]",
  ]);

  if (result.exitCode !== 0) {
    console.error(`Failed to list jobs for run ${runId}: ${result.stderr}`);
    Deno.exit(1);
  }

  console.log(result.stdout);
}

export async function main(): Promise<void> {
  const { remaining: allArgs, owner: flagOwner, repo: flagRepo } = parseRepoFlag(Deno.args);
  // allArgs[0] = group ("gh"), allArgs[1] = command ("list-run-jobs"), rest = positional args
  const remaining = allArgs.slice(2);

  if (remaining.length < 1) {
    console.error("Usage: claude-tools gh list-run-jobs <run_id> [--repo <owner/repo>]");
    Deno.exit(1);
  }

  const runId = remaining[0];

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

  await listRunJobs({ owner, repo, runId });
}
