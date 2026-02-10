{ config, lib, isWSL, ... }:

{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = ''
      local config = wezterm.config_builder()
      return config
    '';
  };

  home.activation.deployWeztermToWindows = lib.mkIf isWSL (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      win_user=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
      if [ -n "$win_user" ]; then
        win_config="/mnt/c/Users/$win_user/.config/wezterm"
        mkdir -p "$win_config"
        cp -rT "${config.home.homeDirectory}/.config/wezterm" "$win_config"
        echo "Deployed WezTerm config to $win_config"
      else
        echo "Warning: Could not detect Windows username, skipping WezTerm Windows deployment" >&2
      fi
    ''
  );
}
