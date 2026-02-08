return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {
          -- Disable default mappings (astrocore / snacks.nvim)
          ["<Leader>ld"] = false,
          ["<Leader>lD"] = false,
          ["<Leader>lk"] = false,
          ["<Leader>ls"] = false,
          ["<Leader>lS"] = false,

          -- Cursor navigation (overrides default <Leader>h and <Leader>l)
          ["<Leader>h"] = { "^", desc = "󰜲 Move to first non-whitespace" },
          ["<Leader>l"] = { "$", desc = "󰜵 Move to end of line" },
          ["<Leader>m"] = { "%", desc = "󰅪 Match nearest [], (), {}" },
        },
        v = {
          ["<Leader>la"] = false,
        },
      },
    },
  },
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      mappings = {
        n = {
          -- Disable default Language Tools group (astrolsp)
          ["<Leader>l"] = false,
          ["<Leader>la"] = false,
          ["<Leader>lA"] = false,
          ["<Leader>lf"] = false,
          ["<Leader>lG"] = false,
          ["<Leader>lh"] = false,
          ["<Leader>ll"] = false,
          ["<Leader>lL"] = false,
          ["<Leader>lr"] = false,
          ["<Leader>lR"] = false,
          ["<Leader>li"] = false,
          ["<Leader>lI"] = false,
        },
        v = {
          ["<Leader>l"] = false,
          ["<Leader>lf"] = false,
        },
        x = {
          ["<Leader>la"] = false,
        },
      },
    },
  },
}
