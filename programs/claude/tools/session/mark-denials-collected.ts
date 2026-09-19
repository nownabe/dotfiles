import { writeCollectedThrough } from "./state.ts";

export function main(): void {
  // Deno.args[0] = group ("session"), [1] = command ("mark-denials-collected"), [2] = timestamp
  const [timestamp, ...rest] = Deno.args.slice(2);
  const parsed = timestamp ? Date.parse(timestamp) : NaN;
  if (Number.isNaN(parsed) || rest.length > 0) {
    console.error("Usage: claude-tools session mark-denials-collected <timestamp>");
    console.error("<timestamp> is the `timestamp` of the last denial that has been triaged.");
    Deno.exit(1);
  }

  // Transcripts use millisecond-precision UTC; store the same shape so that
  // list-denials can compare cursor and timestamps as strings.
  const normalized = new Date(parsed).toISOString();
  writeCollectedThrough(normalized);
  console.log(`Denials through ${normalized} are marked as collected`);
}
