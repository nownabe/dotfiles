{ config, lib, dotfilesDir, ... }:

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
in
{
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
