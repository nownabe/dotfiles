--[=[

  nvim-cmp
  https://docs.astronvim.com/recipes/cmp/

]=]

local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_text(0, line-1, 0, line-1, col, {})[1]:match("^%s*$") == nil
end

return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    local astrocore = require("astrocore")
    local cmp = require("cmp")

    opts.sources = cmp.config.sources({
      -- AstroNvim default sources
      { name = "nvim_lsp", priority = 1000 },
      { name = "luasnip", priority = 750 },
      { name = "buffer", priority = 500 },
      { name = "path", priority = 250 },

      -- Additional sources
      { name = "copilot", priority = 1000 },
    })

    opts.mapping["<Tab>"] = vim.schedule_wrap(function(fallback)
      if cmp.visible() and has_words_before() then
        cmp.confirm({select = true})
      else
        fallback()
      end
    end)
    opts.mapping["<S-Tab>"] = nil

    opts.formatting.format = astrocore.patch_func(opts.formatting.format, function(format, entry, item)
      local vim_item = format(entry, item)

      if entry.source.name == "copilot" then
        vim_item.kind = ""
      end
      vim_item.menu = entry.source.name

      return vim_item
    end)

    -- local colors = require("astronvim.config.colors")
    -- vim.api.nvim_set_hl(0, "CmpItemMenu", { fg = colors.fg, bg = "NONE", italic = true })

    return opts
  end,
}
