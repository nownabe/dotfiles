import { afterEach, beforeEach, describe, it as test } from "@std/testing/bdd";
import { expect } from "@std/expect";
import { join } from "node:path";
import { detectPlatform, loadNotificationConfig, resolveSound } from "./notification.ts";

describe("detectPlatform", () => {
  test("returns a valid platform string", () => {
    expect(["wsl", "macos", "linux", "unknown"]).toContain(detectPlatform());
  });
});

describe("resolveSound", () => {
  const defaultPermissionSound = "C:\\Windows\\Media\\Windows Notify System Generic.wav";
  const defaultWildcardSound = "C:\\Windows\\Media\\tada.wav";

  test("returns default wildcard sound when no notification type", () => {
    expect(resolveSound(undefined, {})).toBe(defaultWildcardSound);
  });

  test("returns default sound for permission_prompt type", () => {
    expect(resolveSound("permission_prompt", {})).toBe(defaultPermissionSound);
  });

  test("returns default wildcard sound for unknown type", () => {
    expect(resolveSound("task_completed", {})).toBe(defaultWildcardSound);
  });

  test("uses config sound override for specific type", () => {
    const config = {
      sounds: { permission_prompt: "C:\\custom\\sound.wav" },
    };
    expect(resolveSound("permission_prompt", config)).toBe("C:\\custom\\sound.wav");
  });

  test("uses config wildcard override", () => {
    const config = {
      sounds: { "*": "C:\\custom\\default.wav" },
    };
    expect(resolveSound("stop", config)).toBe("C:\\custom\\default.wav");
  });

  test("config type-specific sound takes priority over wildcard", () => {
    const config = {
      sounds: {
        "*": "C:\\custom\\default.wav",
        stop: "C:\\custom\\stop.wav",
      },
    };
    expect(resolveSound("stop", config)).toBe("C:\\custom\\stop.wav");
  });

  test("falls back to config wildcard for unmatched type", () => {
    const config = {
      sounds: {
        "*": "C:\\custom\\default.wav",
        stop: "C:\\custom\\stop.wav",
      },
    };
    expect(resolveSound("task_completed", config)).toBe("C:\\custom\\default.wav");
  });
});

describe("loadNotificationConfig", () => {
  let tmpDir: string;
  let originalHome: string | undefined;

  beforeEach(() => {
    tmpDir = Deno.makeTempDirSync({ prefix: "notification-test-" });
    originalHome = Deno.env.get("HOME");
    Deno.env.set("HOME", tmpDir);
  });

  afterEach(() => {
    if (originalHome === undefined) {
      Deno.env.delete("HOME");
    } else {
      Deno.env.set("HOME", originalHome);
    }
    Deno.removeSync(tmpDir, { recursive: true });
  });

  function writeConfig(dir: string, notificationConfig: object) {
    const claudeDir = join(dir, ".claude");
    Deno.mkdirSync(claudeDir, { recursive: true });
    Deno.writeTextFileSync(
      join(claudeDir, "nownabe-claude-hooks.json"),
      JSON.stringify({ notification: notificationConfig }),
    );
  }

  test("returns empty config when no config files exist", () => {
    const cwd = join(tmpDir, "a", "b");
    Deno.mkdirSync(cwd, { recursive: true });
    expect(loadNotificationConfig(cwd)).toEqual({});
  });

  test("loads sounds from HOME config", () => {
    writeConfig(tmpDir, {
      sounds: { "*": "C:\\custom\\sound.wav" },
    });
    expect(loadNotificationConfig(tmpDir)).toEqual({
      sounds: { "*": "C:\\custom\\sound.wav" },
    });
  });

  test("child config overrides parent sounds", () => {
    const projectDir = join(tmpDir, "project");
    Deno.mkdirSync(projectDir, { recursive: true });

    writeConfig(tmpDir, {
      sounds: { "*": "C:\\parent\\sound.wav", stop: "C:\\parent\\stop.wav" },
    });
    writeConfig(projectDir, {
      sounds: { "*": "C:\\child\\sound.wav" },
    });

    const result = loadNotificationConfig(projectDir);
    expect(result.sounds?.["*"]).toBe("C:\\child\\sound.wav");
    expect(result.sounds?.stop).toBe("C:\\parent\\stop.wav");
  });

  test("merges sounds from multiple levels", () => {
    const projectDir = join(tmpDir, "project");
    Deno.mkdirSync(projectDir, { recursive: true });

    writeConfig(tmpDir, {
      sounds: { permission_prompt: "C:\\home\\prompt.wav" },
    });
    writeConfig(projectDir, {
      sounds: { stop: "C:\\project\\stop.wav" },
    });

    const result = loadNotificationConfig(projectDir);
    expect(result.sounds?.permission_prompt).toBe("C:\\home\\prompt.wav");
    expect(result.sounds?.stop).toBe("C:\\project\\stop.wav");
  });

  test("skips malformed JSON files", () => {
    const claudeDir = join(tmpDir, ".claude");
    Deno.mkdirSync(claudeDir, { recursive: true });
    Deno.writeTextFileSync(join(claudeDir, "nownabe-claude-hooks.json"), "not json");

    expect(loadNotificationConfig(tmpDir)).toEqual({});
  });

  test("handles config without sounds field", () => {
    writeConfig(tmpDir, {});
    expect(loadNotificationConfig(tmpDir)).toEqual({});
  });

  test("returns empty config when HOME is not set", () => {
    Deno.env.delete("HOME");
    expect(loadNotificationConfig("/some/path")).toEqual({});
  });
});
