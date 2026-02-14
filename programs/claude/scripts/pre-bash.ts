#!/usr/bin/env bun

/**
 * PreToolUse hook for Bash commands.
 * Runs multiple checkers against the command and returns a deny decision
 * if any checker rejects it.
 */

// --- Types ---

/**
 * Common input fields.
 * @see https://code.claude.com/docs/en/hooks#common-input-fields
 */
interface HookCommonInput {
  /** Current session identifier. */
  session_id: string;
  /** Path to conversation JSON. */
  transcript_path: string;
  /** Current working directory when the hook is invoked. */
  cwd: string;
  /** Current permission mode: "default", "plan", "acceptEdits", "dontAsk", or "bypassPermissions". */
  permission_mode: string;
  /** Name of the event that fired. */
  hook_event_name: string;
}

/**
 * Tool-specific input fields for PreToolUse.
 * @see https://code.claude.com/docs/en/hooks#pretooluse-input
 */
interface HookInput extends HookCommonInput {
  /** Name of the tool being called. */
  tool_name: string;
  /** The parameters sent to the tool. */
  tool_input: {
    /** The command to execute. */
    command: string;
    /** Clear, concise description of what this command does. */
    description?: string;
    /** Optional timeout in milliseconds (max 600000). */
    timeout?: number;
    /** Set to true to run this command in the background. */
    run_in_background?: boolean;
  };
  /** Unique identifier for this tool call. */
  tool_use_id: string;
}

interface DenyResult {
  reason: string;
  suggestion: string;
}

/**
 * Hook output for PreToolUse.
 * @see https://code.claude.com/docs/en/hooks#hook-output
 */
interface HookOutput {
  hookSpecificOutput: {
    /** Name of the event that fired. */
    hookEventName: "PreToolUse";
    /** "allow" bypasses the permission system, "deny" prevents the tool call, "ask" prompts the user to confirm. */
    permissionDecision: "allow" | "deny" | "ask";
    /** For "allow" and "ask", shown to the user but not Claude. For "deny", shown to Claude. */
    permissionDecisionReason?: string;
    /** Modifies the tool's input parameters before execution. Combine with "allow" to auto-approve, or "ask" to show the modified input to the user. */
    updatedInput?: Record<string, unknown>;
    /** String added to Claude's context before the tool executes. */
    additionalContext?: string;
  };
}

// --- Feature: Forbidden Command Patterns ---

interface ForbiddenPatternEntry {
  pattern: string;
  reason: string;
  suggestion: string;
}

/**
 * JSON file format. Supports two forms:
 * - Array form: ForbiddenPatternEntry[]  (patterns only, no ignores)
 * - Object form: { patterns: ForbiddenPatternEntry[], ignore?: string[] }
 *
 * `ignore` lists pattern strings to exclude from the final merged set.
 * A child-level file can use `ignore` to disable patterns defined in parent-level files.
 */
type ForbiddenPatternsFile =
  | ForbiddenPatternEntry[]
  | { patterns: ForbiddenPatternEntry[]; ignore?: string[] };

const FORBIDDEN_PATTERNS_FILENAME = "forbidden-patterns.json";

/**
 * Collect directories from `startDir` up to (and including) `stopDir`.
 * Returns paths from startDir (most specific) to stopDir (least specific).
 */
function collectAncestorDirs(startDir: string, stopDir: string): string[] {
  const { resolve, dirname } = require("path") as typeof import("path");
  const start = resolve(startDir);
  const stop = resolve(stopDir);
  const dirs: string[] = [];
  let current = start;
  for (;;) {
    dirs.push(current);
    if (current === stop) break;
    const parent = dirname(current);
    if (parent === current) break; // reached filesystem root
    current = parent;
  }
  return dirs;
}

/**
 * Load forbidden-patterns.json files from CWD up to HOME.
 * All found patterns are merged. Patterns listed in any file's `ignore`
 * array are excluded from the final set.
 */
function loadForbiddenPatterns(cwd: string): ForbiddenPatternEntry[] {
  const { join } = require("path") as typeof import("path");
  const { existsSync, readFileSync } =
    require("fs") as typeof import("fs");
  const home = process.env.HOME ?? "";
  if (!home) return [];

  const dirs = collectAncestorDirs(cwd, home);
  const allPatterns: ForbiddenPatternEntry[] = [];
  const ignoreSet = new Set<string>();

  for (const dir of dirs) {
    const filePath = join(dir, ".claude", FORBIDDEN_PATTERNS_FILENAME);
    if (!existsSync(filePath)) continue;
    try {
      const raw: ForbiddenPatternsFile = JSON.parse(
        readFileSync(filePath, "utf-8"),
      );
      if (Array.isArray(raw)) {
        allPatterns.push(...raw);
      } else {
        allPatterns.push(...raw.patterns);
        if (raw.ignore) {
          for (const p of raw.ignore) ignoreSet.add(p);
        }
      }
    } catch {
      // skip malformed files
    }
  }

  return allPatterns.filter((entry) => !ignoreSet.has(entry.pattern));
}

function checkForbiddenPatterns(
  command: string,
  patterns: ForbiddenPatternEntry[],
): DenyResult | null {
  for (const { pattern, reason, suggestion } of patterns) {
    if (new RegExp(pattern).test(command)) {
      return { reason, suggestion };
    }
  }
  return null;
}

// --- Checker Pipeline ---

type Checker = (command: string) => DenyResult | null;

// --- Main ---

async function main() {
  const text = await Bun.stdin.text();
  const input: HookInput = JSON.parse(text);
  const command = input.tool_input.command;

  const forbiddenPatterns = loadForbiddenPatterns(input.cwd);
  const checkers: Checker[] = [
    (cmd) => checkForbiddenPatterns(cmd, forbiddenPatterns),
  ];

  for (const checker of checkers) {
    const result = checker(command);
    if (result) {
      const output: HookOutput = {
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          permissionDecision: "deny",
          permissionDecisionReason: `${result.reason} ${result.suggestion}`,
          additionalContext: result.suggestion,
        },
      };
      console.log(JSON.stringify(output));
      process.exit(0);
    }
  }

  // All checks passed — no opinion, let normal permission flow continue.
  process.exit(0);
}

main();
