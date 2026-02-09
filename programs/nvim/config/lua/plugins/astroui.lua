---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = function(_, opts)
    local mocha = require("catppuccin.palettes").get_palette("mocha")
    local function ul(extra)
      local attrs = { underline = true, sp = mocha.surface0 }
      return extra and vim.tbl_extend("force", attrs, extra) or attrs
    end
    return require("astrocore").extend_tbl(opts, {
      colorscheme = "catppuccin",
      status = {
        attributes = {
          buffer_active = ul { bold = true },
          buffer_visible = ul(),
          buffer = ul(),
          buffer_active_close = ul(),
          buffer_visible_close = ul(),
          buffer_close = ul(),
          buffer_active_path = ul(),
          buffer_visible_path = ul(),
          buffer_path = ul(),
          tab_active = ul(),
          tab = ul(),
          tab_close = ul(),
        },
        colors = function(colors)
          colors.buffer_active_fg = mocha.rosewater
          return colors
        end,
      },
    })
  end,
}
