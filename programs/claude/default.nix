{ config, lib, pkgs, dotfilesDir, ... }:

let
  # Symlink each skill file individually (not the skills directory itself)
  # so ~/.claude/skills stays a real directory where unmanaged local skills
  # can coexist. New files in skills/ require re-running `hms` to be linked.
  skillLinks = lib.listToAttrs (
    map (
      file:
      let
        rel = lib.removePrefix "${toString ./skills}/" (toString file);
      in
      {
        name = ".claude/skills/${rel}";
        value.source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/programs/claude/skills/${rel}";
      }
    ) (lib.filesystem.listFilesRecursive ./skills)
  );

  # Run a CLI straight from the working tree rather than the Nix store, so
  # editing the TypeScript takes effect without re-running `hms`.
  # --no-remote enforces the zero-dependency rule: these must start offline
  # and fast, since the hooks run on every Bash tool call.
  denoCli = { name, entrypoint, permissions, quiet ? false }:
    let
      flags = lib.optional quiet "-q"
        ++ [ "--no-config" "--no-lock" "--no-remote" ]
        ++ permissions;
    in
    pkgs.writeShellScriptBin name ''
      exec ${lib.getExe pkgs.deno} run ${lib.concatStringsSep " " flags} \
        "${dotfilesDir}/programs/claude/${entrypoint}" "$@"
    '';
in
{
  home.packages = [
    (denoCli {
      name = "claude-tools";
      entrypoint = "tools/cli.ts";
      # `session` commands read the Claude Code transcripts and keep their
      # cursor under the XDG state dir; nothing else on disk is reachable.
      permissions = [
        "--allow-run=gh"
        "--allow-env=HOME,XDG_STATE_HOME"
        "--allow-read=${config.home.homeDirectory}/.claude/projects,${config.xdg.stateHome}/claude-tools"
        "--allow-write=${config.xdg.stateHome}/claude-tools"
      ];
    })
    (denoCli {
      name = "claude-hooks";
      entrypoint = "hooks/cli.ts";
      # Deno logs an Info line for every --allow-run entry it cannot resolve to a
      # binary, and powershell.exe is absent from PATH unless WSL interop puts it
      # there. Dropping that candidate would silence it too, but it is the
      # fallback for hosts that do not mount C: at /mnt/c, so quieten the hook
      # instead — it runs on every Bash tool call. -q hides only diagnostics;
      # module and runtime errors still reach stderr.
      quiet = true;
      # Config files are read from CWD up to HOME, so reads cannot be scoped.
      # The two powershell paths mirror POWERSHELL_CANDIDATES in notification.ts.
      permissions = [
        "--allow-read"
        "--allow-env=HOME"
        "--allow-run=powershell.exe,/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
      ];
    })
  ];

  home.file = skillLinks // {
    ".claude/CLAUDE.md".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/programs/claude/CLAUDE.md";

    ".claude/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/programs/claude/settings.json";

    ".claude/nownabe-claude-hooks.json".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/programs/claude/nownabe-claude-hooks.json";

    ".claude/scripts/statusline-command.sh".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/programs/claude/scripts/statusline-command.sh";
  };
}
