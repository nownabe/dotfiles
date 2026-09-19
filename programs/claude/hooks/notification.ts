/**
 * Notification hook for Claude Code.
 * Sends OS-native notifications (currently WSL/Windows only).
 * Reads notification config from `nownabe-claude-hooks.json` files
 * in the directory hierarchy (CWD up to HOME), with child overrides.
 */

import { loadConfig } from "./config.ts";

// --- Types ---

interface NotificationInput {
  title: string;
  message: string;
  notification_type?: string;
}

interface NotificationConfig {
  sounds?: Record<string, string>;
}

export type Platform = "wsl" | "macos" | "linux" | "unknown";

// --- Constants ---

const DEFAULT_SOUNDS: Record<string, string> = {
  permission_prompt: "C:\\Windows\\Media\\Windows Notify System Generic.wav",
  "*": "C:\\Windows\\Media\\tada.wav",
};

/**
 * Candidates tried in order. PATH lookup covers the usual WSL interop setup;
 * the absolute path covers shells whose PATH omits the Windows directories.
 * Both must stay in sync with `--allow-run` in programs/claude/default.nix.
 */
const POWERSHELL_CANDIDATES = [
  "powershell.exe",
  "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe",
];

// --- Platform Detection ---

export function detectPlatform(): Platform {
  try {
    const version = Deno.readTextFileSync("/proc/version").toLowerCase();
    if (version.includes("microsoft") || version.includes("wsl")) {
      return "wsl";
    }
  } catch {
    // /proc/version doesn't exist (e.g. macOS)
  }

  if (Deno.build.os === "darwin") return "macos";
  if (Deno.build.os === "linux") return "linux";
  return "unknown";
}

// --- Config Loading ---

export function loadNotificationConfig(cwd: string): NotificationConfig {
  const config = loadConfig(cwd);
  return config.notification ?? {};
}

// --- Sound Resolution ---

export function resolveSound(
  notificationType: string | undefined,
  config: NotificationConfig,
): string {
  const sounds = { ...DEFAULT_SOUNDS, ...config.sounds };

  if (notificationType && sounds[notificationType]) {
    return sounds[notificationType];
  }

  return sounds["*"] ?? DEFAULT_SOUNDS["*"];
}

// --- WSL Notification ---

function escapePowershellString(s: string): string {
  return s.replace(/'/g, "''");
}

export function notifyWsl(title: string, message: string, sound: string): void {
  const script = [
    `$sound = New-Object System.Media.SoundPlayer '${escapePowershellString(sound)}'`,
    `$sound.playsync()`,
    `Add-Type -AssemblyName System.Windows.Forms`,
    `$notify = New-Object System.Windows.Forms.NotifyIcon`,
    `$notify.Icon = [System.Drawing.SystemIcons]::Information`,
    `$notify.BalloonTipTitle = '${escapePowershellString(title)}'`,
    `$notify.BalloonTipText = '${escapePowershellString(message)}'`,
    `$notify.Visible = $true`,
    `$notify.ShowBalloonTip(5000)`,
    `Start-Sleep -Seconds 1`,
    `$notify.Dispose()`,
  ].join("; ");

  for (const powershell of POWERSHELL_CANDIDATES) {
    let result;
    try {
      result = new Deno.Command(powershell, {
        args: ["-NoProfile", "-NonInteractive", "-Command", script],
        stdout: "null",
        stderr: "null",
      }).outputSync();
    } catch {
      continue; // not at this path — try the next candidate
    }

    if (!result.success) {
      console.error("Failed to send Windows notification");
    }
    return;
  }

  console.error("powershell.exe not found, skipping notification");
}

// --- Main ---

export async function main() {
  const text = await new Response(Deno.stdin.readable).text();
  const input: NotificationInput = JSON.parse(text);

  const title = input.title ?? "Claude Code";
  const message = input.message ?? "";

  const config = loadNotificationConfig(Deno.cwd());
  const sound = resolveSound(input.notification_type, config);

  switch (detectPlatform()) {
    case "wsl":
      notifyWsl(title, message, sound);
      break;
    case "macos":
    case "linux":
    case "unknown":
      // Future: add native notifications for other platforms
      break;
  }
}
