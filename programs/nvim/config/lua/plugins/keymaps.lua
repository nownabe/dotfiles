return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {
          ["<Leader>h"] = { "^", desc = "Move to first non-whitespace" },
          ["<Leader>l"] = { "$", desc = "Move to end of line" },
          ["<Leader>m"] = { "%", desc = "Match nearest [], (), {}" },
        },
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<Leader>h", icon = "󰜲" },
        { "<Leader>l", icon = "󰜵" },
        { "<Leader>m", icon = "󰅪" },
      },
    },
  },
}
