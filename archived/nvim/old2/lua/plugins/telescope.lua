return {
  "nvim-telescope/telescope.nvim",
  opts = function(_, opts)
    local actions = require "telescope.actions"
    opts.defaults.mappings.i["<C-h>"] = actions.select_horizontal

    -- https://github.com/nvim-telescope/telescope.nvim/blob/b4da76be54691e854d3e0e02c36b0245f945c2c7/lua/telescope/config.lua#L707-L728
    opts.defaults.vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--hidden",
    }
  end,
}
