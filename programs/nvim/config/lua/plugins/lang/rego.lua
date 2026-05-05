-- Rego language support
-- LSP: regols

return {
  {
    "AstroNvim/astrolsp",
    optional = true,
    opts = function(_, opts)
      opts.servers = require("astrocore").list_insert_unique(opts.servers or {}, { "regols" })
    end,
  },
  {
    "AstroNvim/astrocore",
    optional = true,
    ---@type AstroCoreOpts
    opts = {
      treesitter = { ensure_installed = { "rego" } },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "regols" })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
        "regols",
      })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        rego = { "opa_check" },
      },
    },
  },
}
