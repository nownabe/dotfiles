/**
 * Unified config loader for nownabe-claude-hooks.
 * Loads and deep-merges config files from CWD up to HOME.
 */

import { dirname, join, resolve } from "node:path";
import type { AllowedPatternConfig, ForbiddenPatternConfig } from "./pre-bash.ts";

// --- Types ---

export interface Config {
  preBash?: {
    allowedPatterns?: Record<string, AllowedPatternConfig>;
    forbiddenPatterns?: Record<string, ForbiddenPatternConfig>;
  };
  notification?: {
    sounds?: Record<string, string>;
  };
}

// --- Constants ---

const CONFIG_FILENAME = "nownabe-claude-hooks.json";
const LOCAL_CONFIG_FILENAME = "nownabe-claude-hooks.local.json";

// --- Helpers ---

/**
 * Collect directories from `startDir` up to (and including) `stopDir`.
 * Returns paths from startDir (most specific) to stopDir (least specific).
 */
export function collectAncestorDirs(startDir: string, stopDir: string): string[] {
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
 * Recursively deep merge two objects.
 * - Objects: recursively merged (keys from `override` win)
 * - Arrays/primitives: replaced entirely by `override`
 */
export function deepMerge(
  base: Record<string, unknown>,
  override: Record<string, unknown>,
): Record<string, unknown> {
  const result: Record<string, unknown> = { ...base };
  for (const key of Object.keys(override)) {
    const baseVal = base[key];
    const overrideVal = override[key];
    if (isPlainObject(baseVal) && isPlainObject(overrideVal)) {
      result[key] = deepMerge(baseVal, overrideVal);
    } else {
      result[key] = overrideVal;
    }
  }
  return result;
}

function isPlainObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/** Read and parse a JSON file, returning null if it is missing or malformed. */
function readJsonFile(path: string): unknown {
  try {
    return JSON.parse(Deno.readTextFileSync(path));
  } catch {
    return null;
  }
}

/**
 * Load config files from CWD up to HOME and deep merge them.
 *
 * File priority (highest first, per directory from CWD to HOME):
 * 1. CWD/.claude/nownabe-claude-hooks.local.json
 * 2. CWD/.claude/nownabe-claude-hooks.json
 * 3. <parent>/.claude/nownabe-claude-hooks.local.json
 * 4. <parent>/.claude/nownabe-claude-hooks.json
 * 5. ... up to HOME
 *
 * Merge: Start from the lowest-priority file, deep merge upward.
 */
export function loadConfig(cwd: string): Config {
  const home = Deno.env.get("HOME") ?? "";
  if (!home) return {};

  // Highest priority first; per directory the local file outranks the non-local one.
  const configFiles = collectAncestorDirs(cwd, home).flatMap((dir) => [
    join(dir, ".claude", LOCAL_CONFIG_FILENAME),
    join(dir, ".claude", CONFIG_FILENAME),
  ]);

  // Merge from lowest priority (last) to highest priority (first).
  let merged: Record<string, unknown> = {};
  for (const filePath of configFiles.reverse()) {
    const content = readJsonFile(filePath);
    if (isPlainObject(content)) {
      merged = deepMerge(merged, content);
    }
  }

  return merged as Config;
}
