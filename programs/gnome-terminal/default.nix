{ lib, isWSL, ... }:

let
  # Default GNOME Terminal profile UUID (shipped by Ubuntu).
  profile = "b1dcc9dd-5262-4d8d-a863-c897e6d979b9";

  # Catppuccin Mocha palette
  # https://github.com/catppuccin/gnome-terminal
  palette = [
    "#45475A"
    "#F38BA8"
    "#A6E3A1"
    "#F9E2AF"
    "#89B4FA"
    "#F5C2E7"
    "#94E2D5"
    "#BAC2DE"
    "#585B70"
    "#F38BA8"
    "#A6E3A1"
    "#F9E2AF"
    "#89B4FA"
    "#F5C2E7"
    "#94E2D5"
    "#A6ADC8"
  ];
in
# GNOME Terminal exists only on native Linux desktops, not WSL2.
lib.mkIf (!isWSL) {
  dconf.settings = {
    "org/gnome/terminal/legacy/profiles:" = {
      default = profile;
      list = [ profile ];
    };

    "org/gnome/terminal/legacy/profiles:/:${profile}" = {
      visible-name = "Catppuccin Mocha";

      use-theme-colors = false;
      background-color = "#1E1E2E";
      foreground-color = "#CDD6F4";
      inherit palette;

      bold-color-same-as-fg = true;

      cursor-colors-set = true;
      cursor-background-color = "#F5E0DC";
      cursor-foreground-color = "#1E1E2E";

      highlight-colors-set = true;
      highlight-background-color = "#F5E0DC";
      highlight-foreground-color = "#1E1E2E";

      # Make the palette fully visible (Mocha is a dark theme).
      use-transparent-background = false;
    };
  };
}
