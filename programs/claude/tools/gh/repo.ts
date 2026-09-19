export interface CommandResult {
  stdout: string;
  stderr: string;
  exitCode: number;
}

export interface RunCommandFn {
  (args: string[]): Promise<CommandResult>;
}

export async function runGh(args: string[]): Promise<CommandResult> {
  const { code, stdout, stderr } = await new Deno.Command("gh", {
    args,
    stdout: "piped",
    stderr: "piped",
  }).output();
  const decoder = new TextDecoder();
  return {
    stdout: decoder.decode(stdout).trim(),
    stderr: decoder.decode(stderr).trim(),
    exitCode: code,
  };
}

export async function resolveRepo(
  runCommand: RunCommandFn = runGh,
): Promise<{ owner: string; repo: string }> {
  const result = await runCommand([
    "repo",
    "view",
    "--json",
    "nameWithOwner",
    "--jq",
    ".nameWithOwner",
  ]);

  if (result.exitCode !== 0) {
    console.error(`Failed to detect repository: ${result.stderr}`);
    Deno.exit(1);
  }

  const [owner, repo] = result.stdout.split("/");
  if (!owner || !repo) {
    console.error(`Unexpected repository format: ${result.stdout}`);
    Deno.exit(1);
  }

  return { owner, repo };
}

export function parseRepoFlag(args: string[]): {
  remaining: string[];
  owner?: string;
  repo?: string;
} {
  const repoIndex = args.indexOf("--repo");
  if (repoIndex === -1) {
    return { remaining: args };
  }

  const repoValue = args[repoIndex + 1];
  if (!repoValue) {
    console.error("--repo requires a value in the format <owner/repo>");
    Deno.exit(1);
  }

  const [owner, repo] = repoValue.split("/");
  if (!owner || !repo) {
    console.error("--repo value must be in the format <owner/repo>");
    Deno.exit(1);
  }

  const remaining = [...args.slice(0, repoIndex), ...args.slice(repoIndex + 2)];
  return { remaining, owner, repo };
}
