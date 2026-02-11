local wezterm = require("wezterm")

local M = {}

function M.apply_to_config(config)
  config.font = wezterm.font("UbuntuSansMono Nerd Font Mono")
  config.font_size = 13.0
  config.adjust_window_size_when_changing_font_size = false

  -- Light hinting for smoother glyph shapes
  config.freetype_load_target = "Light"
  -- Subpixel anti-aliasing for sharper rendering on LCD displays
  config.freetype_render_target = "HorizontalLcd"
end

return M
