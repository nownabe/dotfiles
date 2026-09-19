import type { CommandResult, RunCommandFn } from "./repo.ts";

/** A `gh` runner that replays `responses` in order and records every call. */
export function createMockRunner(
  responses: CommandResult[],
): { fn: RunCommandFn; calls: string[][] } {
  const calls: string[][] = [];
  let callIndex = 0;
  const fn: RunCommandFn = (args) => {
    calls.push(args);
    return Promise.resolve(responses[callIndex++]);
  };
  return { fn, calls };
}

/**
 * Replace `Deno.exit` with a throwing stub so a command's failure path can be
 * asserted instead of killing the test runner. Always `restore()` afterwards.
 */
export function stubExit(): { codes: number[]; restore: () => void } {
  const codes: number[] = [];
  const original = Deno.exit;
  Deno.exit = ((code?: number) => {
    codes.push(code ?? 0);
    throw new Error(`Deno.exit(${code ?? 0})`);
  }) as typeof Deno.exit;
  return {
    codes,
    restore: () => {
      Deno.exit = original;
    },
  };
}
