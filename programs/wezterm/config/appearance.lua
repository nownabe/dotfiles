local M = {}

function M.apply_to_config(config)
  config.color_scheme = "Catppuccin Mocha"

  -- Hide the title bar, keep the resizable border
  config.window_decorations = "RESIZE"

  -- Always show the tab bar using the retro style
  config.enable_tab_bar = true
  config.use_fancy_tab_bar = false

  -- Tab bar positioning and limits
  config.tab_bar_at_bottom = true
  config.tab_max_width = 30
  config.show_new_tab_button_in_tab_bar = false

  -- Tab bar colors (Catppuccin Mocha)
  config.colors = {
    tab_bar = {
      background = "#181825", -- mantle
    },
  }

  -- Dim inactive panes to visually distinguish the active one
  config.inactive_pane_hsb = {
    saturation = 0.8,
    brightness = 0.7,
  }
end

return M
