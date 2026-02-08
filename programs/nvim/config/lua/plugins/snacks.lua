return {
  "folke/snacks.nvim",
  init = function()
    vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#1e1e2e", blend = 90 })
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function() vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#1e1e2e", blend = 90 }) end,
    })
  end,
  opts = {
    picker = {
      win = {
        input = {
          keys = {
            ["<C-h>"] = { "edit_split", mode = { "i", "n" } },
          },
        },
      },
    },
  },
}
