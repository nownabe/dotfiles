import { dirname, join } from "node:path";

function home(): string {
  const home = Deno.env.get("HOME");
  if (!home) {
    console.error("HOME is not set");
    Deno.exit(1);
  }
  return home;
}

/** One directory per project, each holding that project's session transcripts. */
export function projectsDir(): string {
  return join(home(), ".claude", "projects");
}

// The cursor is per-machine state, not configuration, so it lives under
// XDG_STATE_HOME rather than next to the config in the dotfiles repository.
function cursorPath(): string {
  const stateHome = Deno.env.get("XDG_STATE_HOME") || join(home(), ".local", "state");
  return join(stateHome, "claude-tools", "denials-collected-through");
}

/** Timestamp of the last triaged denial, or null when nothing has been triaged yet. */
export function readCollectedThrough(): string | null {
  try {
    return Deno.readTextFileSync(cursorPath()).trim() || null;
  } catch (e) {
    if (e instanceof Deno.errors.NotFound) return null;
    throw e;
  }
}

export function writeCollectedThrough(timestamp: string): void {
  const path = cursorPath();
  Deno.mkdirSync(dirname(path), { recursive: true });
  Deno.writeTextFileSync(path, timestamp + "\n");
}
