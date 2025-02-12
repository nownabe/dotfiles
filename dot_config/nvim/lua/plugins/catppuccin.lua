--[=[
  
  https://github.com/catppuccin/nvim
  
]=]

return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  opts = {
    flavour = "mocha",
    transparent_background = true,
    color_overrides = {
      mocha = {
        -- rosewater = "#f5e0dc",
        -- flamingo = "#f2cdcd",
        -- pink = "#f5c2e7",
        -- mauve = "#cba6f7",
        -- red = "#f38ba8",
        -- maroon = "#eba0ac",
        -- peach = "#fab387",
        -- yellow = "#f9e2af",
        -- green = "#a6e3a1",
        -- teal = "#94e2d5",
        -- sky = "#89dceb",
        -- sapphire = "#74c7ec",
        -- blue = "#89b4fa",
        -- lavender = "#b4befe",
        -- text = "#cdd6f4",
        -- subtext1 = "#bac2de",
        -- subtext0 = "#a6adc8",
        -- overlay2 = "#9399b2",
        -- overlay1 = "#7f849c",
        -- overlay0 = "#6c7086",
        -- surface2 = "#585b70",
        --surface1 = "#45475a",
        surface1 = "#4F5164",
        --surface0 = "#313244",
        surface0 = "#3B3C4E",
        -- base = "#1e1e2e",
        -- mantle = "#181825",
        -- crust = "#11111b",
      },
    },
    custom_highlights = function(colors)
      return {
        NotifyBackground = { bg = colors.base },
        NeoTreeTabActive = { fg = colors.rosewater, bold = true },
      }
    end,
  },
}
