{ lib, isWSL, ... }:

{
  home.file = {
    ".claude/settings.json".source = ./settings.json;

    ".claude/scripts/pre-bash.ts" = {
      source = ./scripts/pre-bash.ts;
    };

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
