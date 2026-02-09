---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = function(_, opts)
    opts.colorscheme = "catppuccin"

    if not opts.status then opts.status = {} end

    local orig_colors = opts.status.colors
    opts.status.colors = function(colors)
      if type(orig_colors) == "function" then orig_colors(colors) end
      colors.buffer_active_fg = "#f5e0dc" -- rosewater
      return colors
    end
  end,
}
