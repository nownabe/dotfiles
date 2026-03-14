-- YAML language support
-- LSP: yamlls with schemastore, Formatting: oxfmt

return {
  {
    "b0o/schemastore.nvim",
    lazy = true,
  },
  {
    "AstroNvim/astrolsp",
    optional = true,
    opts = function(_, opts)
      opts.servers = require("astrocore").list_insert_unique(opts.servers or {}, { "yamlls" })
      opts.config = vim.tbl_deep_extend("force", opts.config or {}, {
        yamlls = {
          on_new_config = function(config)
            if not config.settings.yaml then config.settings.yaml = {} end
            config.settings.yaml.schemas =
              vim.tbl_extend("force", config.settings.yaml.schemas or {}, require("schemastore").yaml.schemas())
          end,
          settings = {
            yaml = {
              validate = true,
              schemaStore = {
                enable = false, -- use schemastore.nvim instead
                url = "",
              },
            },
          },
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "yaml" })
      end
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "yamlls" })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
        "yaml-language-server",
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        yaml = { "oxfmt" },
      },
    },
  },
}
