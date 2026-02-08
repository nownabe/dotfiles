return {
  "folke/snacks.nvim",
  opts = {
    indent = {
      indent = {
        enabled = false,
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
