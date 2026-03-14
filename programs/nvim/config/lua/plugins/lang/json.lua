-- JSON language support
-- LSP: jsonls with schemastore, Formatter: oxfmt

return {
  {
    "b0o/schemastore.nvim",
    lazy = true,
  },
  {
    "AstroNvim/astrolsp",
    optional = true,
    opts = function(_, opts)
      opts.servers = require("astrocore").list_insert_unique(opts.servers or {}, { "jsonls", "oxfmt" })
      opts.config = vim.tbl_deep_extend("force", opts.config or {}, {
        jsonls = {
          on_new_config = function(config)
            if not config.settings.json then config.settings.json = {} end
            config.settings.json.schemas = require("schemastore").json.schemas()
            config.settings.json.validate = { enable = true }
          end,
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "json", "jsonc" })
      end
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "jsonls", "oxfmt" })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
        "json-lsp",
        "oxfmt",
      })
    end,
  },
}
