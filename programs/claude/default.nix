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
      # `docs` serves the Markdown under docs/ straight from the working tree.
      permissions = [
        "--allow-run=gh"
        "--allow-read=${dotfilesDir}/programs/claude/docs"
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
      # XDG_CONFIG_HOME locates the machine-local private-patterns files, and
      # git answers whether the repository at hand is private (see
      # hooks/private-patterns.ts). The two powershell paths mirror
      # POWERSHELL_CANDIDATES in notification.ts.
      permissions = [
        "--allow-read"
        "--allow-env=HOME,XDG_CONFIG_HOME"
        "--allow-run=git,powershell.exe,/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
      ];
    })
  ];

  home.file = skillLinks // {
    ".claude/CLAUDE.md".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/programs/claude/CLAUDE.md";

    ".claude/nownabe-claude-hooks.json".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/programs/claude/nownabe-claude-hooks.json";

    ".claude/scripts/statusline-command.sh".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/programs/claude/scripts/statusline-command.sh";
  };

  # Claude Code writes machine-local state into ~/.claude/settings.json at
  # runtime: the chosen model, the auto-mode environment profile, notification
  # flags. Not a symlink into this repository, then — that turned every such
  # write into an uncommitted change to a public file. The live file is a
  # plain file, and each activation deep-merges the managed keys from
  # settings.json into it: managed keys win, everything else stays as Claude
  # Code wrote it. A key removed from settings.json is not removed from the
  # live file; delete it by hand.
  home.activation.mergeClaudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    managed="${dotfilesDir}/programs/claude/settings.json"
    live="${config.home.homeDirectory}/.claude/settings.json"
    jq="${pkgs.jq}/bin/jq"

    mkdir -p "$(dirname "$live")"

    # Earlier generations deployed the live file as a symlink to $managed.
    # Whether the link is still there or Home Manager has already cleaned it
    # up, its content is the working-tree copy of $managed, so start from
    # that and let the merge below pick up whatever Claude Code had written.
    if [ -L "$live" ]; then
      rm "$live"
    fi
    if [ ! -f "$live" ]; then
      cp "$managed" "$live"
      chmod u+w "$live"
    fi

    merged=$("$jq" -s '.[0] * .[1]' "$live" "$managed") || exit 1
    printf '%s\n' "$merged" > "$live"
  '';
}
