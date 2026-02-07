{ lib, isWSL, ... }:

{
  home.file = {
    ".claude/settings.json".source = ./settings.json;
    ".claude/CLAUDE.md".source = ./CLAUDE.md;

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
