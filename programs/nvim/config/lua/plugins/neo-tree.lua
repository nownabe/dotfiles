return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    opts.filesystem.filtered_items = {
      visible = true,
      hide_dotfiles = false,
      hide_gitignored = false,
    }
    opts.window.mappings["<C-h>"] = "open_split"
    opts.window.mappings["<C-v>"] = "open_vsplit"
  end,
}
