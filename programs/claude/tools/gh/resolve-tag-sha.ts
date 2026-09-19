import { type RunCommandFn, runGh } from "./repo.ts";

export interface ResolveTagShaOptions {
  repo: string;
  tag: string;
}

export async function resolveTagSha(
  options: ResolveTagShaOptions,
  runCommand: RunCommandFn = runGh,
): Promise<string> {
  const { repo, tag } = options;

  const refResult = await runCommand([
    "api",
    `repos/${repo}/git/ref/tags/${tag}`,
    "--jq",
    ".object",
  ]);

  if (refResult.exitCode !== 0) {
    console.error(`Failed to resolve tag "${tag}" in ${repo}: ${refResult.stderr}`);
    Deno.exit(1);
  }

  const refObject: { type: string; sha: string } = JSON.parse(refResult.stdout);

  if (refObject.type === "commit") {
    return refObject.sha;
  }

  if (refObject.type === "tag") {
    const tagResult = await runCommand([
      "api",
      `repos/${repo}/git/tags/${refObject.sha}`,
      "--jq",
      ".object.sha",
    ]);

    if (tagResult.exitCode !== 0) {
      console.error(`Failed to dereference annotated tag "${tag}" in ${repo}: ${tagResult.stderr}`);
      Deno.exit(1);
    }

    return tagResult.stdout;
  }

  console.error(`Unexpected object type "${refObject.type}" for tag "${tag}" in ${repo}`);
  Deno.exit(1);
}

export async function main(): Promise<void> {
  // Deno.args[0] = group ("gh"), [1] = command ("resolve-tag-sha"), rest = positional args
  const remaining = Deno.args.slice(2);

  if (remaining.length < 2) {
    console.error("Usage: claude-tools gh resolve-tag-sha <owner/repo> <tag>");
    Deno.exit(1);
  }

  const [repo, tag] = remaining;

  const sha = await resolveTagSha({ repo, tag });
  console.log(`${repo}@${sha} # ${tag}`);
}
