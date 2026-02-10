local M = {}

function M.apply_to_config(config)
  config.color_scheme = "Catppuccin Mocha"
  config.window_decorations = "RESIZE"
  config.enable_tab_bar = true
  config.hide_tab_bar_if_only_one_tab = true
  config.use_fancy_tab_bar = false
  config.inactive_pane_hsb = {
    saturation = 0.8,
    brightness = 0.7,
  }
end

return M
