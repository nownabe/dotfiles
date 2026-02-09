-- Catppuccin Mocha palette (hardcoded to avoid require timing issues)
local surface0 = "#313244"
local rosewater = "#f5e0dc"

local function ul(extra)
  local attrs = { underline = true, sp = surface0 }
  return extra and vim.tbl_extend("force", attrs, extra) or attrs
end

---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = function(_, opts)
    opts.colorscheme = "catppuccin"

    if not opts.status then opts.status = {} end
    if not opts.status.attributes then opts.status.attributes = {} end

    opts.status.attributes.buffer_active = ul { bold = true }
    opts.status.attributes.buffer_visible = ul()
    opts.status.attributes.buffer = ul()
    opts.status.attributes.buffer_active_close = ul()
    opts.status.attributes.buffer_visible_close = ul()
    opts.status.attributes.buffer_close = ul()
    opts.status.attributes.buffer_active_path = ul()
    opts.status.attributes.buffer_visible_path = ul()
    opts.status.attributes.buffer_path = ul()
    opts.status.attributes.tab_active = ul()
    opts.status.attributes.tab = ul()
    opts.status.attributes.tab_close = ul()

    local orig_colors = opts.status.colors
    opts.status.colors = function(colors)
      if type(orig_colors) == "function" then orig_colors(colors) end
      colors.buffer_active_fg = rosewater
      return colors
    end
  end,
}
