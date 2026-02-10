local M = {}

function M.apply_to_config(config)
  config.color_scheme = "Catppuccin Mocha"

  -- Hide the title bar, keep the resizable border
  config.window_decorations = "RESIZE"

  -- Always show the tab bar using the retro style
  config.enable_tab_bar = true
  config.use_fancy_tab_bar = false

  -- Dim inactive panes to visually distinguish the active one
  config.inactive_pane_hsb = {
    saturation = 0.8,
    brightness = 0.7,
  }
end

return M
