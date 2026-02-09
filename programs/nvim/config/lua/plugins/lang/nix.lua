-- Nix language support

return {
  {
    "AstroNvim/astrolsp",
    optional = true,
    opts = {
      config = {
        nil_ls = {
          settings = {
            ["nil"] = {
              formatting = {
                command = { "nixfmt" },
              },
            },
          },
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "nix" })
      end
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "nil_ls" })
    end,
  },
  {
    "jay-babu/mason-null-ls.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "nixfmt" })

      if not opts.handlers then opts.handlers = {} end

      opts.handlers.statix = function(source_name, methods)
        local null_ls = require("null-ls")
        for _, method in ipairs(methods) do
          null_ls.register(null_ls.builtins[method][source_name])
        end
      end

      opts.handlers.deadnix = function(source_name, methods)
        local null_ls = require("null-ls")
        for _, method in ipairs(methods) do
          null_ls.register(null_ls.builtins[method][source_name])
        end
      end
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "nil", "nixfmt" })
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local null_ls = require("null-ls")
      if not opts.sources then opts.sources = {} end
      local sources = {
        null_ls.builtins.diagnostics.statix,
        null_ls.builtins.code_actions.statix,
        null_ls.builtins.diagnostics.deadnix,
      }
      vim.list_extend(opts.sources, sources)
    end,
  },
}
