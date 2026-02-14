#!/usr/bin/env bun

/**
 * PreToolUse hook for Bash commands.
 * Runs multiple checkers against the command and returns a deny decision
 * if any checker rejects it.
 */

// --- Types ---

interface HookInput {
  /** Current session identifier */
  session_id: string;
  /** Path to conversation JSON */
  transcript_path: string;
  /** Current working directory when the hook is invoked */
  cwd: string;
  /** Current permission mode: "default", "plan", "acceptEdits", "dontAsk", or "bypassPermissions" */
  permission_mode: string;
  /** Name of the event that fired */
  hook_event_name: string;
  /** Name of the tool being called */
  tool_name: string;
  /** The parameters sent to the tool */
  tool_input: {
    command: string;
    description?: string;
    timeout?: number;
    run_in_background?: boolean;
  };
  /** Unique identifier for this tool call */
  tool_use_id: string;
}

interface DenyResult {
  reason: string;
  suggestion: string;
}

interface HookOutput {
  hookSpecificOutput: {
    /** Name of the event that fired */
    hookEventName: "PreToolUse";
    /** "allow" bypasses the permission system, "deny" prevents the tool call, "ask" prompts the user to confirm */
    permissionDecision: "allow" | "deny" | "ask";
    /** For "allow" and "ask", shown to the user but not Claude. For "deny", shown to Claude */
    permissionDecisionReason?: string;
    /** Modifies the tool's input parameters before execution. Combine with "allow" to auto-approve, or "ask" to show the modified input to the user */
    updatedInput?: Record<string, unknown>;
    /** String added to Claude's context before the tool executes */
    additionalContext?: string;
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
