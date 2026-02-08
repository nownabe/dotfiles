return {
  {
    "folke/which-key.nvim",
    opts_extend = { "spec" },
    opts = {
      spec = {
        { "<Leader>h", "^", desc = "Move to first non-whitespace", icon = "󰜲", order = 1 },
        { "<Leader>l", "$", desc = "Move to end of line", icon = "󰜵", order = 2 },
        { "<Leader>m", "%", desc = "Match nearest [], (), {}", icon = "󰅪", order = 3 },
      },
    },
  },
}
