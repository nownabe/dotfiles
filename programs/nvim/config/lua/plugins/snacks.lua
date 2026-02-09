return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      win = {
        input = {
          keys = {
            ["<C-h>"] = { "edit_split", mode = { "i", "n" } },
            ["<C-v>"] = { "edit_vsplit", mode = { "i", "n" } },
          },
        },
      },
    },
  },
}
