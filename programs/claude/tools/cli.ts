import { commands as gh } from "./gh/index.ts";
import { parseRepoFlag } from "./gh/repo.ts";

const subcommands: Record<string, Record<string, () => Promise<void>>> = {
  gh,
};

// Extract --repo flag from all args so it can appear anywhere (e.g. before the subcommand name)
const { remaining: cleanedArgs } = parseRepoFlag(Deno.args);

const group = cleanedArgs[0];
const name = cleanedArgs[1];

if (group === "docs") {
  const { main } = await import("./docs.ts");
  await main();
  Deno.exit(0);
}

if (!group || !(group in subcommands)) {
  const available = [...Object.keys(subcommands), "docs"].join(", ");
  console.error(group ? `Unknown command group: ${group}` : "No command specified");
  console.error(`Available commands: ${available}`);
  Deno.exit(1);
}

const groupCommands = subcommands[group];

if (!name || !(name in groupCommands)) {
  const available = Object.keys(groupCommands).join(", ");
  console.error(name ? `Unknown command: ${group} ${name}` : `No subcommand specified`);
  console.error(`Available commands for '${group}': ${available}`);
  Deno.exit(1);
}

await groupCommands[name]();
