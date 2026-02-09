-- Catppuccin Mocha palette
local mantle = "#181825"
local surface0 = "#313244"

return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    -- Set bg on tabline root so file icons (which don't use get_attributes)
    -- inherit it via heirline's hl merge chain
    if opts.tabline then
      opts.tabline.hl = { bg = mantle }
    end

    -- Enable surround on winbar for better visibility
    local status = require("astroui.status")
    opts.winbar = {
      init = function(self)
        self.bufnr = vim.api.nvim_get_current_buf()
      end,
      fallthrough = false,
      { -- inactive winbar
        condition = function()
          return not status.condition.is_active()
        end,
        status.component.separated_path(),
        status.component.file_info({
          file_icon = {
            hl = status.hl.file_icon("winbar"),
            padding = { left = 0 },
          },
          filename = {},
          filetype = false,
          file_read_only = false,
          hl = status.hl.get_attributes("winbarnc", true),
          update = "BufEnter",
        }),
      },
      { -- active winbar
        status.component.breadcrumbs({
          hl = status.hl.get_attributes("winbar", true),
        }),
      },
    }
  end,
}
