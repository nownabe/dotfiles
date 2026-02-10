local wezterm = require("wezterm")

local M = {}

function M.apply_to_config(config)
  config.font = wezterm.font("UbuntuSansMono Nerd Font Mono")
  config.font_size = 13.0

  -- Light hinting for smoother glyph shapes
  config.freetype_load_target = "Light"
  -- Subpixel anti-aliasing for sharper rendering on LCD displays
  config.freetype_render_target = "HorizontalLcd"
end

return M
