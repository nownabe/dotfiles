/**
 * Machine-local private patterns, shared with the global git hooks.
 *
 * Two files under $XDG_CONFIG_HOME/git (default ~/.config/git), one entry per
 * line, `#` comments and blank lines ignored, matched case-insensitively:
 *
 *   private-patterns  regexes that must never reach a public place
 *   private-remotes   regexes over `git remote get-url origin`; a repository
 *                     whose origin matches is private, and the patterns are
 *                     not enforced there
 *
 * Both files stay outside every repository on purpose: what they name is the
 * very thing worth keeping out of a public one. The Deno hooks and the bash
 * git hooks read the same files, so one list covers file content, command
 * lines, staged changes and commit messages alike.
 */

import { join } from "node:path";

export const PATTERNS_FILE = "private-patterns";
export const REMOTES_FILE = "private-remotes";

export interface PrivateMatch {
  reason: string;
  suggestion: string;
}

export function configDir(): string {
  const xdg = Deno.env.get("XDG_CONFIG_HOME");
  if (xdg) return join(xdg, "git");
  return join(Deno.env.get("HOME") ?? "", ".config", "git");
}

/** Active lines of a pattern file: trimmed, comments and blanks dropped. */
export function parsePatternFile(text: string): string[] {
  return text
    .split("\n")
    .map((line) => line.trim())
    .filter((line) => line.length > 0 && !line.startsWith("#"));
}

function readPatternFile(path: string): string[] {
  try {
    return parsePatternFile(Deno.readTextFileSync(path));
  } catch {
    return [];
  }
}

export function isPrivateRemote(originUrl: string, remotePatterns: string[]): boolean {
  return remotePatterns.some((pattern) => new RegExp(pattern, "i").test(originUrl));
}

/** `git remote get-url origin` for `dir`, or null when there is none. */
export function originUrl(dir: string): string | null {
  try {
    const result = new Deno.Command("git", {
      args: ["remote", "get-url", "origin"],
      cwd: dir,
      stdout: "piped",
      stderr: "null",
    }).outputSync();
    if (!result.success) return null;
    const url = new TextDecoder().decode(result.stdout).trim();
    return url.length > 0 ? url : null;
  } catch {
    return null;
  }
}

/**
 * Patterns to enforce for work rooted at `dir`. Empty when none are
 * configured, or when `dir` belongs to a private remote. A directory outside
 * any repository is treated as public: that is where a PR body written to a
 * scratch file lives before `--body-file` publishes it.
 */
export function loadPrivatePatterns(
  dir: string,
  getOrigin: (dir: string) => string | null = originUrl,
): string[] {
  const configPath = configDir();
  const patterns = readPatternFile(join(configPath, PATTERNS_FILE));
  if (patterns.length === 0) return [];

  const remotes = readPatternFile(join(configPath, REMOTES_FILE));
  if (remotes.length > 0) {
    const origin = getOrigin(dir);
    if (origin !== null && isPrivateRemote(origin, remotes)) return [];
  }
  return patterns;
}

/** One match per pattern that hits any of `texts`, or null. */
export function findPrivateMatches(texts: string[], patterns: string[]): PrivateMatch[] | null {
  const matches: PrivateMatch[] = [];
  for (const pattern of patterns) {
    const re = new RegExp(pattern, "i");
    if (texts.some((text) => re.test(text))) {
      matches.push({
        reason: `Matches the private pattern \`${pattern}\` from ${
          join(configDir(), PATTERNS_FILE)
        }.`,
        suggestion:
          "This is not a private repository. Remove the private name, host or port entirely; it must not appear in commits, pull request or issue text, or any file that may be published.",
      });
    }
  }
  return matches.length > 0 ? matches : null;
}
