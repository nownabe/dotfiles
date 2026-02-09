-- Catppuccin Mocha palette
local mantle = "#181825"
local surface0 = "#313244"
local rosewater = "#f5e0dc"

---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = function(_, opts)
    opts.colorscheme = "catppuccin"

    if not opts.status then opts.status = {} end
    if not opts.status.attributes then opts.status.attributes = {} end

    -- Background colors on every tabline component for visual separation
    opts.status.attributes.buffer_active = { bold = true, bg = surface0 }
    opts.status.attributes.buffer_visible = { bg = mantle }
    opts.status.attributes.buffer = { bg = mantle }
    opts.status.attributes.buffer_active_close = { bg = surface0 }
    opts.status.attributes.buffer_visible_close = { bg = mantle }
    opts.status.attributes.buffer_close = { bg = mantle }
    opts.status.attributes.buffer_active_path = { bg = surface0 }
    opts.status.attributes.buffer_visible_path = { bg = mantle }
    opts.status.attributes.buffer_path = { bg = mantle }
    opts.status.attributes.tab_active = { bold = true, bg = surface0 }
    opts.status.attributes.tab = { bg = mantle }
    opts.status.attributes.tab_close = { bg = mantle }

    local orig_colors = opts.status.colors
    opts.status.colors = function(colors)
      if type(orig_colors) == "function" then orig_colors(colors) end
      -- Fill / sidebar background
      colors.tabline_bg = mantle
      -- Active tab fg
      colors.buffer_active_fg = rosewater
      -- Tab page bg (used via include_bg=true)
      colors.tab_active_bg = surface0
      colors.tab_bg = mantle
      colors.tab_close_bg = mantle
      return colors
    end
  end,
}
