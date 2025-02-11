return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    opts.window.mappings["<C-h>"] = "open_split"
    opts.window.mappings["<C-v>"] = "open_vsplit"
    return opts
  end,
}
