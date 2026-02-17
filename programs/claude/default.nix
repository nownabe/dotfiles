{ lib, isWSL, ... }:

{
  home.file = {
    ".claude/CLAUDE.md".source = ./CLAUDE.md;

    ".claude/settings.json".source = ./settings.json;

    ".claude/nownabe-claude-hooks.json".source = ./nownabe-claude-hooks.json;

    ".claude/scripts/statusline-command.sh" = {
      source = ./scripts/statusline-command.sh;
      executable = true;
    };

    ".claude/scripts/notify-windows" = lib.mkIf isWSL {
      source = ./scripts/notify-windows;
      executable = true;
    };
  };
}
