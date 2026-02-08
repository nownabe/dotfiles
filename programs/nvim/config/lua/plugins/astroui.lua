---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = function(_, opts)
    local mocha = require("catppuccin.palettes").get_palette("mocha")
    return require("astrocore").extend_tbl(opts, {
      colorscheme = "catppuccin",
      status = {
        attributes = {
          buffer_active = { bold = true },
        },
        colors = function(colors)
          colors.buffer_active_fg = mocha.rosewater
          return colors
        end,
      },
    })
  end,
}
