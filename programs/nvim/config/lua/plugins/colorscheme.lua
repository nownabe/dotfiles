return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      color_overrides = {
        mocha = {
          surface1 = "#4F5164",
          surface0 = "#3B3C4E",
        },
      },
      custom_highlights = function(colors)
        return {
          NotifyBackground = { bg = colors.base },
          NeoTreeTabActive = { fg = colors.rosewater, bold = true },
        }
      end,
    },
  },
}
