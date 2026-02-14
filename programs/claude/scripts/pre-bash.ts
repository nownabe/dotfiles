#!/usr/bin/env bun

/**
 * PreToolUse hook for Bash commands.
 * Runs multiple checkers against the command and returns a deny decision
 * if any checker rejects it.
 */

// --- Types ---

interface HookInput {
  session_id: string;
  tool_name: string;
  tool_input: {
    command: string;
    description?: string;
    timeout?: number;
    run_in_background?: boolean;
  };
}

interface DenyResult {
  reason: string;
  suggestion: string;
}

interface HookOutput {
  hookSpecificOutput: {
    hookEventName: "PreToolUse";
    permissionDecision: "deny";
    permissionDecisionReason: string;
    additionalContext: string;
  };
}

// --- Feature: Forbidden Command Patterns ---

interface ForbiddenPattern {
  pattern: RegExp;
  reason: string;
  suggestion: string;
}

const forbiddenPatterns: ForbiddenPattern[] = [
  {
    pattern: /\bgit\s+-C\b/,
    reason: "`git -C` is forbidden.",
    suggestion:
      "Run git commands from the target directory directly instead of using `git -C`.",
  },
];

function checkForbiddenPatterns(command: string): DenyResult | null {
  for (const { pattern, reason, suggestion } of forbiddenPatterns) {
    if (pattern.test(command)) {
      return { reason, suggestion };
    }
  }
  return null;
}

// --- Checker Pipeline ---

type Checker = (command: string) => DenyResult | null;

const checkers: Checker[] = [checkForbiddenPatterns];

// --- Main ---

async function main() {
  const text = await Bun.stdin.text();
  const input: HookInput = JSON.parse(text);
  const command = input.tool_input.command;

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
