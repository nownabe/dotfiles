return {
  "folke/snacks.nvim",
  opts = {
    indent = {
      indent = {
        char = "┊",
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
