local wezterm = require("wezterm")

local M = {}

function M.apply_to_config(config)
  config.font = wezterm.font("UbuntuSans Nerd Font")
  config.font_size = 13.0
end

return M
