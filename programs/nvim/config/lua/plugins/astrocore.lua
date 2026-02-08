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
}
