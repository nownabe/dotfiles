import { parseRepoFlag, resolveRepo, type RunCommandFn, runGh } from "./repo.ts";

export interface ListSubIssuesOptions {
  owner: string;
  repo: string;
  issueNumber: number;
}

export async function listSubIssues(
  options: ListSubIssuesOptions,
  runCommand: RunCommandFn = runGh,
): Promise<void> {
  const { owner, repo, issueNumber } = options;

  const result = await runCommand([
    "api",
    `repos/${owner}/${repo}/issues/${issueNumber}/sub_issues`,
  ]);

  if (result.exitCode !== 0) {
    console.error(`Failed to list sub-issues for #${issueNumber}: ${result.stderr}`);
    Deno.exit(1);
  }

  console.log(result.stdout);
}

export async function main(): Promise<void> {
  const { remaining: allArgs, owner: flagOwner, repo: flagRepo } = parseRepoFlag(Deno.args);
  // allArgs[0] = group ("gh"), allArgs[1] = command ("list-sub-issues"), rest = positional args
  const remaining = allArgs.slice(2);

  if (remaining.length < 1) {
    console.error("Usage: claude-tools gh list-sub-issues <issue_number> [--repo <owner/repo>]");
    Deno.exit(1);
  }

  const issueNumber = Number(remaining[0]);

  if (Number.isNaN(issueNumber)) {
    console.error("Issue number must be a valid integer");
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

  await listSubIssues({ owner, repo, issueNumber });
}
