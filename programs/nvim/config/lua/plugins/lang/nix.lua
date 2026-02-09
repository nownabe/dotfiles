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
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed =
        require("astrocore").list_insert_unique(opts.ensure_installed, { "nil", "nixfmt" })
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local null_ls = require("null-ls")
      if not opts.sources then opts.sources = {} end
      local sources = {}
      if vim.fn.executable("statix") == 1 then
        vim.list_extend(sources, {
          null_ls.builtins.diagnostics.statix,
          null_ls.builtins.code_actions.statix,
        })
      end
      if vim.fn.executable("deadnix") == 1 then
        table.insert(sources, null_ls.builtins.diagnostics.deadnix)
      end
      vim.list_extend(opts.sources, sources)
    end,
  },
}
