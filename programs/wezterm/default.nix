{ config, lib, isWSL, dotfilesDir, ... }:

{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = ''
      local config = wezterm.config_builder()

      require("config.font").apply_to_config(config)
      require("config.appearance").apply_to_config(config)
      require("config.tab").setup()
      require("config.statusbar").setup()
      require("config.keymaps").apply_to_config(config)

      -- Launch WSL by default when running on Windows
      if wezterm.target_triple:find("windows") then
        for _, domain in ipairs(wezterm.default_wsl_domains()) do
          if domain.name:find("^WSL:Ubuntu") then
            config.default_domain = domain.name
            break
          end
        end
      end

      return config
    '';
  };

  xdg.configFile."wezterm/config".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/programs/wezterm/config";

  home.activation.deployWeztermToWindows = lib.mkIf isWSL (
    lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      win_user=$(/mnt/c/Windows/System32/cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
      if [ -n "$win_user" ]; then
        win_config="/mnt/c/Users/$win_user/.config/wezterm"
        rm -rf "$win_config"
        mkdir -p "$win_config"
        cp -rTL "${config.home.homeDirectory}/.config/wezterm" "$win_config"
        chmod -R u+w "$win_config"
        echo "Deployed WezTerm config to $win_config"
      else
        echo "Warning: Could not detect Windows username, skipping WezTerm Windows deployment" >&2
      fi
    ''
  );
}
