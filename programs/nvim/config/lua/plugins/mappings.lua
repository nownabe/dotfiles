return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {
          -- Disable default Language Tools group
          ["<Leader>la"] = false,
          ["<Leader>lA"] = false,
          ["<Leader>ld"] = false,
          ["<Leader>lD"] = false,
          ["<Leader>lf"] = false,
          ["<Leader>lG"] = false,
          ["<Leader>lh"] = false,
          ["<Leader>li"] = false,
          ["<Leader>lI"] = false,
          ["<Leader>lk"] = false,
          ["<Leader>ll"] = false,
          ["<Leader>lL"] = false,
          ["<Leader>lr"] = false,
          ["<Leader>lR"] = false,
          ["<Leader>ls"] = false,
          ["<Leader>lS"] = false,

          -- Cursor navigation (overrides default <Leader>h and <Leader>l)
          ["<Leader>h"] = { "^", desc = "󰜲 Move to first non-whitespace" },
          ["<Leader>l"] = { "$", desc = "󰜵 Move to end of line" },
          ["<Leader>m"] = { "%", desc = "󰅪 Match nearest [], (), {}" },
        },
        v = {
          ["<Leader>l"] = false,
          ["<Leader>la"] = false,
          ["<Leader>lf"] = false,
        },
        x = {
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
          ["<Leader>l"] = false,
          ["<Leader>la"] = false,
          ["<Leader>lA"] = false,
          ["<Leader>lf"] = false,
          ["<Leader>lh"] = false,
          ["<Leader>lI"] = false,
          ["<Leader>lk"] = false,
          ["<Leader>ll"] = false,
          ["<Leader>lL"] = false,
          ["<Leader>lr"] = false,
          ["<Leader>lR"] = false,
          ["<Leader>lG"] = false,
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
