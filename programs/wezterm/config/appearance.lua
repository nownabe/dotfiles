local M = {}

function M.apply_to_config(config)
  config.color_scheme = "Catppuccin Mocha"

  -- Hide the title bar, keep the resizable border
  config.window_decorations = "RESIZE"

  -- Show the tab bar only when there are multiple tabs, using the retro style
  config.enable_tab_bar = true
  -- config.hide_tab_bar_if_only_one_tab = true
  config.use_fancy_tab_bar = false

  -- Dim inactive panes to visually distinguish the active one
  config.inactive_pane_hsb = {
    saturation = 0.8,
    brightness = 0.7,
  }
end

return M
