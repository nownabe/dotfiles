/**
 * PreToolUse hook for file-writing tools (Write, Edit, NotebookEdit).
 * Denies the call when the content being written matches a forbidden pattern
 * from the config, or a machine-local private pattern (see
 * private-patterns.ts) when the file does not live in a private repository.
 *
 * Complements pre-bash rather than duplicating it: pre-bash only ever sees the
 * command line, so content that reaches a repository through a file — a commit
 * message passed with `git commit -F`, a PR body passed with
 * `gh pr create --body-file` — is invisible to it.
 */

import { dirname, join } from "node:path";
import { loadConfig } from "./config.ts";
import { type ActivePattern, type ForbiddenPatternConfig, parsePattern } from "./pre-bash.ts";
import {
  configDir,
  findPrivateMatches,
  loadPrivatePatterns,
  PATTERNS_FILE,
  REMOTES_FILE,
} from "./private-patterns.ts";

// --- Types ---

interface HookInput {
  cwd: string;
  tool_name: string;
  /** Write uses `content`, Edit `new_string`, NotebookEdit `new_source`. */
  tool_input: {
    file_path?: string;
    content?: string;
    new_string?: string;
    new_source?: string;
  };
}

interface DenyResult {
  reason: string;
  suggestion: string;
}

interface HookOutput {
  hookSpecificOutput: {
    hookEventName: "PreToolUse";
    permissionDecision: "allow" | "deny" | "ask";
    permissionDecisionReason?: string;
    additionalContext?: string;
  };
}

// --- Config ---

/** Load forbidden content patterns from `config.preWrite.forbiddenPatterns`. */
export function loadForbiddenPatterns(cwd: string): ActivePattern[] {
  const config = loadConfig(cwd);
  const patterns = config.preWrite?.forbiddenPatterns ?? {};
  return Object.entries(patterns)
    .filter(([, entry]) => !entry.disabled)
    .map(([pattern, entry]) => {
      const active = entry as Exclude<ForbiddenPatternConfig, { disabled: true }>;
      return {
        pattern,
        reason: active.reason,
        suggestion: active.suggestion,
        type: active.type,
        multiline: active.multiline,
      };
    });
}

// --- Checking ---

/**
 * Collect every piece of text this tool call would write.
 * Unknown tools contribute nothing, so they are never denied.
 */
export function extractContent(toolInput: HookInput["tool_input"]): string[] {
  return [toolInput.content, toolInput.new_string, toolInput.new_source].filter(
    (value): value is string => typeof value === "string" && value.length > 0,
  );
}

export function checkForbiddenPatterns(
  contents: string[],
  patterns: ActivePattern[],
): DenyResult[] | null {
  const results: DenyResult[] = [];

  for (const { pattern, reason, suggestion, type, multiline } of patterns) {
    const re = parsePattern(pattern, type, multiline);

    for (const content of contents) {
      re.lastIndex = 0;
      if (re.test(content)) {
        results.push({ reason, suggestion });
        break;
      }
    }
  }
  return results.length > 0 ? results : null;
}

/**
 * Files that may legitimately name private things whatever repository the
 * session is in: Claude Code's own state under ~/.claude (memory, settings)
 * and the private-pattern files themselves.
 */
export function isPrivateSafePath(
  filePath: string,
  home: string = Deno.env.get("HOME") ?? "",
  config: string = configDir(),
): boolean {
  if (home.length > 0 && filePath.startsWith(join(home, ".claude") + "/")) return true;
  return filePath === join(config, PATTERNS_FILE) || filePath === join(config, REMOTES_FILE);
}

/**
 * Private patterns are judged by where the file lives, not by the session's
 * cwd: a file inside a private repository's worktree may name it, while a
 * scratch file outside any repository may be published next.
 */
export function checkPrivatePatterns(
  contents: string[],
  filePath: string | undefined,
  cwd: string,
): DenyResult[] | null {
  if (filePath !== undefined && isPrivateSafePath(filePath)) return null;
  const dir = filePath !== undefined ? dirname(filePath) : cwd;
  return findPrivateMatches(contents, loadPrivatePatterns(dir));
}

// --- Main ---

export async function main() {
  const text = await new Response(Deno.stdin.readable).text();
  const input: HookInput = JSON.parse(text);
  const cwd = input.cwd ?? Deno.cwd();
  const toolInput = input.tool_input ?? {};

  const contents = extractContent(toolInput);
  if (contents.length === 0) Deno.exit(0);

  const results = [
    ...(checkForbiddenPatterns(contents, loadForbiddenPatterns(cwd)) ?? []),
    ...(checkPrivatePatterns(contents, toolInput.file_path, cwd) ?? []),
  ];
  if (results.length === 0) Deno.exit(0);

  const output: HookOutput = {
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: results.map((r) => `${r.reason} ${r.suggestion}`).join("\n"),
      additionalContext: results.map((r) => r.suggestion).join("\n"),
    },
  };
  console.log(JSON.stringify(output));
  Deno.exit(0);
}
