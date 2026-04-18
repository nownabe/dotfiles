{ config, dotfilesDir, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    sideloadInitLua = true;
  };

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/programs/nvim/config";
}
