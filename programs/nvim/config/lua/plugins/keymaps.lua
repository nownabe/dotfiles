return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {
          ["<Leader>h"] = { "^", desc = "Move to first non-whitespace", icon = "󰜲" },
          ["<Leader>l"] = { "$", desc = "Move to end of line", icon = "󰜵" },
          ["<Leader>m"] = { "%", desc = "Match nearest [], (), {}", icon = "󰅪" },
        },
      },
    },
  },
}
