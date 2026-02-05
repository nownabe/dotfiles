{ lib, isWSL, ... }:

{
  home.file = {
    ".claude/scripts/statusline-command.sh" = {
      source = ./config/statusline-command.sh;
      executable = true;
    };

    ".claude/scripts/notify-windows" = lib.mkIf isWSL {
      source = ./config/notify-windows;
      executable = true;
    };
  };
}
