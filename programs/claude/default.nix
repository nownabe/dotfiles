{ config, dotfilesDir, ... }:

{
  home.file = {
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
