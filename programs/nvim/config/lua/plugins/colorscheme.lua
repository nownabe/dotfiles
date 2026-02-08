return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      custom_highlights = function(colors)
        return {
          NormalFloat = { bg = colors.base },
          FloatBorder = { bg = colors.base },
        }
      end,
    },
  },
}
