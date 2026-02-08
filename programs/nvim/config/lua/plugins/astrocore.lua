return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {
          -- Disable default Home Screen mapping
          ["<Leader>h"] = false,
          -- Disable default Language Tools group
          ["<Leader>l"] = false,
          ["<Leader>la"] = false,
          ["<Leader>lA"] = false,
          ["<Leader>ld"] = false,
          ["<Leader>lD"] = false,
          ["<Leader>lf"] = false,
          ["<Leader>lG"] = false,
          ["<Leader>lh"] = false,
          ["<Leader>ll"] = false,
          ["<Leader>lL"] = false,
          ["<Leader>lr"] = false,
          ["<Leader>lR"] = false,
          ["<Leader>ls"] = false,
        },
        v = {
          ["<Leader>l"] = false,
          ["<Leader>la"] = false,
          ["<Leader>lf"] = false,
        },
      },
    },
  },
}
