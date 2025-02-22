return {
  "nvim-telescope/telescope.nvim",
  opts = function(_, opts)
    local actions = require "telescope.actions"
    opts.defaults.mappings.i["<C-h>"] = actions.select_horizontal
  end,
}
