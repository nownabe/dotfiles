-- Oxfmt formatter (via conform.nvim)
-- Mason install + filetypes without dedicated lang files
-- Per-language oxfmt formatters_by_ft are configured in each language file

return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        graphql = { "oxfmt" },
        vue = { "oxfmt" },
      },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
        "oxfmt",
      })
    end,
  },
}
