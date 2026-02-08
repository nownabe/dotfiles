return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      integrations = {
        snacks = true,
      },
      custom_highlights = function(colors)
        return {
          LineNr = { fg = colors.overlay0 },
          NormalFloat = { bg = "NONE" },
          FloatBorder = { bg = "NONE" },
          FloatTitle = { bg = "NONE" },
          TabLineFill = { bg = "NONE", underline = true, sp = colors.surface0 },
          TabLine = { fg = colors.overlay0, bg = "NONE", underline = true, sp = colors.surface0 },
          TabLineSel = { fg = colors.rosewater, bg = "NONE", bold = true, underline = true, sp = colors.surface0 },
        }
      end,
    },
  },
}
