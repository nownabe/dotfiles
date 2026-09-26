// Collects the tool calls Claude Code did not execute from the session
// transcripts, and keeps a cursor so later runs list only untriaged ones.
// Used by the triage-denied-commands skill alone; see SKILL.md for the
// `deno run` invocation.

import { dirname, join } from "node:path";
import { splitCommand } from "../../../programs/claude/hooks/pre-bash.ts";

const USAGE = `Usage:
  denials.ts list [--all]     denied tool calls, one JSON line each, oldest first
  denials.ts list --summary   counts by what stopped the call and command name
  denials.ts mark <timestamp> record that denials through <timestamp> are triaged`;

export interface Denial {
  timestamp: string;
  sessionId: string;
  cwd: string;
  /** Claude Code's `toolDenialKind` (permission-rule, automode-blocked, user-rejected, ...), or `asked`. */
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
  const text = typeof result === "string"
    ? result
    : JSON.stringify(result) ?? "";
  return text.replace(/^Error: /, "").trim();
}

const ASKED = "asked";

/**
 * Pair every denied tool call in one transcript with the `tool_use` it
 * answers. AskUserQuestion rejections are answers to Claude, not blocked
 * commands, so they are skipped.
 *
 * An approved permission prompt leaves no trace in the transcript, so Bash
 * calls that ran and match one of `askRules` (`permissions.ask` entries) are
 * reported as kind `asked`: they waited on the user though nothing denied
 * them.
 */
export function extractDenials(
  lines: Iterable<string>,
  askRules: string[] = [],
): Denial[] {
  const askPatterns = askRules.flatMap((rule) => {
    const pattern = bashRulePattern(rule);
    return pattern ? [{ rule, pattern }] : [];
  });
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
        if (block.type === "tool_use" && block.id) {
          toolUses.set(block.id, block);
        }
      }
      continue;
    }

    const record = (
      kind: string,
      use: ContentBlock | undefined,
      reason: string,
    ) =>
      denials.push({
        timestamp: entry.timestamp ?? "",
        sessionId: entry.sessionId ?? "",
        cwd: entry.cwd ?? "",
        kind,
        tool: use?.name ?? "unknown",
        command: describeInput(use?.input ?? {}),
        reason,
      });

    if (!entry.toolDenialKind) {
      for (const block of contentBlocks(entry)) {
        const use = toolUses.get(block.tool_use_id ?? "");
        const command = use?.input?.command;
        if (use?.name !== "Bash" || typeof command !== "string") continue;
        const subs = simpleCommands(command);
        const asked = askPatterns.find(({ pattern }) =>
          subs.some((sub) => pattern.test(sub))
        );
        if (asked) record(ASKED, use, `permissions.ask: ${asked.rule}`);
      }
      continue;
    }
    const use = toolUses.get(contentBlocks(entry)[0]?.tool_use_id ?? "");
    if (use?.name === "AskUserQuestion") continue;
    record(entry.toolDenialKind, use, describeResult(entry.toolUseResult));
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
export async function readAllDenials(
  dir: string,
  askRules: string[] = [],
): Promise<Denial[]> {
  const denials: Denial[] = [];
  for await (const path of transcripts(dir)) {
    denials.push(
      ...extractDenials(
        (await Deno.readTextFile(path)).split("\n"),
        askRules,
      ),
    );
  }
  return denials.sort((a, b) => a.timestamp.localeCompare(b.timestamp));
}

type Stopper = "hook" | "rule/prompt" | "automode" | "user" | "asked";

function stopper(d: Denial): Stopper {
  if (d.kind === ASKED) return "asked";
  if (d.kind.startsWith("automode")) return "automode";
  if (d.kind === "user-rejected") return "user";
  return /hook error|is forbidden/.test(d.reason) ? "hook" : "rule/prompt";
}

const ASSIGNMENT = /^\w+=(?:"[^"]*"|'[^']*'|\S*)\s*/;

// The simple commands of a command line with the scaffolding peeled off:
// `(`, loop/branch keywords, VAR=value and `timeout N` are not what the call
// was for.
function simpleCommands(command: string): string[] {
  return splitCommand(command).flatMap((part) => part.split("\n")).map(
    (raw) => {
      let sub = raw.trim().replace(/^\(\s*/, "")
        .replace(/^(?:do|then|else|!)\s+/, "");
      while (ASSIGNMENT.test(sub)) sub = sub.replace(ASSIGNMENT, "");
      return sub.replace(/^timeout\s+\S+\s+/, "");
    },
  );
}

// `gh api` and `gh pr` are different decisions; `curl -s` and `curl` are not.
const SUBCOMMAND_TOOLS = new Set(["gh", "git", "deno", "bun", "npm", "nix"]);

function commandName(command: string): string {
  for (const sub of simpleCommands(command)) {
    const [name, subcommand] = sub.split(/\s+/);
    if (!name || name === "cd") continue;
    return SUBCOMMAND_TOOLS.has(name) && /^[a-z][\w-]*$/.test(subcommand ?? "")
      ? `${name} ${subcommand}`
      : name;
  }
  return command.split(/\s+/)[0];
}

/**
 * A matcher for one simple command from a `Bash(...)` permission rule:
 * `Bash(gh api:*)` and `Bash(gh api *)` both match `gh api` and
 * `gh api repos/x`. Non-Bash rules yield null.
 */
export function bashRulePattern(rule: string): RegExp | null {
  const body = /^Bash\((.+)\)$/.exec(rule)?.[1];
  if (!body) return null;
  const source = body.replace(/:\*$/, " *").split("*")
    .map((part) => part.replace(/[.+?^${}()|[\]\\]/g, "\\$&"))
    .join(".*")
    .replace(/ \.\*$/, "(?: .*)?");
  return new RegExp(`^${source}$`, "s");
}

// Hook denials and asked calls group by the rule that fired (an asked call's
// first command is often scaffolding like `git log` before the `gh api`);
// everything else by command name.
function groupKey(d: Denial): string {
  if (stopper(d) === "asked") return d.reason;
  if (stopper(d) === "hook") {
    return d.reason
      .replace(/^PreToolUse:\w+ hook error: /, "")
      .split(/(?<=\.)\s/)[0]
      .slice(0, 70);
  }
  return d.tool === "Bash" ? commandName(d.command) : d.tool;
}

/** `count\tstopper\tgroup\texample`, one line per group, largest first. */
export function summarize(denials: Denial[]): string {
  const groups = new Map<string, { count: number; example: string }>();
  for (const d of denials) {
    const key = `${stopper(d)}\t${groupKey(d)}`;
    const group = groups.get(key) ?? {
      count: 0,
      example: d.command.replace(/\s+/g, " ").slice(0, 100),
    };
    group.count++;
    groups.set(key, group);
  }
  return [...groups]
    .sort(([a, ga], [b, gb]) => gb.count - ga.count || a.localeCompare(b))
    .map(([key, g]) => `${g.count}\t${key}\t${g.example}`)
    .join("\n");
}

function home(): string {
  const home = Deno.env.get("HOME");
  if (!home) fail("HOME is not set");
  return home;
}

// The cursor is per-machine state, so it lives under XDG_STATE_HOME rather
// than in the repository next to this script.
function cursorPath(): string {
  const stateHome = Deno.env.get("XDG_STATE_HOME") ||
    join(home(), ".local", "state");
  return join(stateHome, "triage-denied-commands", "collected-through");
}

// The live settings, not the repository copy: that is what Claude Code
// enforces, and `hms` merges the managed ask rules into it.
function askRules(): string[] {
  const settings = JSON.parse(
    Deno.readTextFileSync(join(home(), ".claude", "settings.json")),
  );
  const rules: unknown[] = settings.permissions?.ask ?? [];
  return rules.filter((rule): rule is string => typeof rule === "string");
}

function readCollectedThrough(): string | null {
  try {
    return Deno.readTextFileSync(cursorPath()).trim() || null;
  } catch (e) {
    if (e instanceof Deno.errors.NotFound) return null;
    throw e;
  }
}

function fail(message: string): never {
  console.error(message);
  Deno.exit(1);
}

async function list(args: string[]): Promise<void> {
  if (args.some((arg) => arg !== "--all" && arg !== "--summary")) fail(USAGE);
  const collectedThrough = args.includes("--all")
    ? null
    : readCollectedThrough();

  const projectsDir = join(home(), ".claude", "projects");
  const denials = (await readAllDenials(projectsDir, askRules())).filter(
    (d) => collectedThrough === null || d.timestamp > collectedThrough,
  );

  if (args.includes("--summary")) {
    if (denials.length > 0) console.log(summarize(denials));
  } else {
    for (const denial of denials) console.log(JSON.stringify(denial));
  }
  console.error(
    collectedThrough
      ? `${denials.length} denial(s) after ${collectedThrough}`
      : `${denials.length} denial(s) in total`,
  );
}

function mark(args: string[]): void {
  const [timestamp, ...rest] = args;
  const parsed = timestamp ? Date.parse(timestamp) : NaN;
  if (Number.isNaN(parsed) || rest.length > 0) fail(USAGE);

  // Transcripts use millisecond-precision UTC; store the same shape so that
  // `list` can compare cursor and timestamps as strings.
  const normalized = new Date(parsed).toISOString();
  const path = cursorPath();
  Deno.mkdirSync(dirname(path), { recursive: true });
  Deno.writeTextFileSync(path, normalized + "\n");
  console.log(`Denials through ${normalized} are marked as collected`);
}

if (import.meta.main) {
  const [command, ...args] = Deno.args;
  if (command === "list") await list(args);
  else if (command === "mark") mark(args);
  else fail(USAGE);
}
