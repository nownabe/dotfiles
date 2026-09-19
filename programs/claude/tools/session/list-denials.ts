import { join } from "node:path";
import { projectsDir, readCollectedThrough } from "./state.ts";

export interface Denial {
  timestamp: string;
  sessionId: string;
  cwd: string;
  /** Claude Code's `toolDenialKind`: permission-rule, automode-blocked, user-rejected, ... */
  kind: string;
  tool: string;
  /** The Bash command line, or the file path / URL for other tools. */
  command: string;
  reason: string;
}

interface ContentBlock {
  type?: string;
  id?: string;
  name?: string;
  input?: Record<string, unknown>;
  tool_use_id?: string;
}

interface TranscriptEntry {
  type?: string;
  timestamp?: string;
  sessionId?: string;
  cwd?: string;
  toolDenialKind?: string;
  toolUseResult?: unknown;
  message?: { content?: unknown };
}

function contentBlocks(entry: TranscriptEntry): ContentBlock[] {
  const content = entry.message?.content;
  return Array.isArray(content) ? (content as ContentBlock[]) : [];
}

function describeInput(input: Record<string, unknown>): string {
  const target = input.command ?? input.file_path ?? input.url;
  return typeof target === "string" ? target : JSON.stringify(input);
}

function describeResult(result: unknown): string {
  const text = typeof result === "string" ? result : JSON.stringify(result) ?? "";
  return text.replace(/^Error: /, "").trim();
}

/**
 * Pair every denied tool call in one transcript with the `tool_use` it answers.
 * AskUserQuestion rejections are answers to Claude, not blocked commands, so
 * they are skipped.
 */
export function extractDenials(lines: Iterable<string>): Denial[] {
  const toolUses = new Map<string, ContentBlock>();
  const denials: Denial[] = [];

  for (const line of lines) {
    let entry: TranscriptEntry;
    try {
      entry = JSON.parse(line);
    } catch {
      continue;
    }
    if (!entry || typeof entry !== "object") continue;

    if (entry.type === "assistant") {
      for (const block of contentBlocks(entry)) {
        if (block.type === "tool_use" && block.id) toolUses.set(block.id, block);
      }
      continue;
    }

    if (!entry.toolDenialKind) continue;
    const use = toolUses.get(contentBlocks(entry)[0]?.tool_use_id ?? "");
    const tool = use?.name ?? "unknown";
    if (tool === "AskUserQuestion") continue;

    denials.push({
      timestamp: entry.timestamp ?? "",
      sessionId: entry.sessionId ?? "",
      cwd: entry.cwd ?? "",
      kind: entry.toolDenialKind,
      tool,
      command: describeInput(use?.input ?? {}),
      reason: describeResult(entry.toolUseResult),
    });
  }

  return denials;
}

async function* transcripts(dir: string): AsyncGenerator<string> {
  for await (const entry of Deno.readDir(dir)) {
    const path = join(dir, entry.name);
    if (entry.isDirectory) yield* transcripts(path);
    else if (entry.name.endsWith(".jsonl")) yield path;
  }
}

/** Every denial under `dir` (recursively), oldest first. */
export async function readAllDenials(dir: string): Promise<Denial[]> {
  const denials: Denial[] = [];
  for await (const path of transcripts(dir)) {
    denials.push(...extractDenials((await Deno.readTextFile(path)).split("\n")));
  }
  return denials.sort((a, b) => a.timestamp.localeCompare(b.timestamp));
}

export async function main(): Promise<void> {
  // Deno.args[0] = group ("session"), [1] = command ("list-denials"), rest = flags
  const args = Deno.args.slice(2);
  const all = args.includes("--all");
  if (args.some((arg) => arg !== "--all")) {
    console.error("Usage: claude-tools session list-denials [--all]");
    Deno.exit(1);
  }

  const collectedThrough = all ? null : readCollectedThrough();
  const denials = (await readAllDenials(projectsDir())).filter(
    (d) => collectedThrough === null || d.timestamp > collectedThrough,
  );

  for (const denial of denials) console.log(JSON.stringify(denial));
  console.error(
    collectedThrough
      ? `${denials.length} denial(s) after ${collectedThrough}`
      : `${denials.length} denial(s) in total`,
  );
}
