return {
  "folke/snacks.nvim",
  opts = {
    indent = {
      indent = {
        only_scope = true,
      },
    },
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
