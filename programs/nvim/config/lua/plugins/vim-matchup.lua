-- https://github.com/andymass/vim-matchup
-- Based on https://github.com/AstroNvim/astrocommunity/blob/main/lua/astrocommunity/motion/vim-matchup/init.lua
return {
  "andymass/vim-matchup",
  event = "User AstroFile",
  specs = {
    { "nvim-treesitter/nvim-treesitter", optional = true },
    {
      "AstroNvim/astrocore",
      opts = {
        options = {
          g = {
            matchup_matchparen_nomode = "i",
            matchup_matchparen_deferred = 1,
          },
        },
      },
    },
  },
}
