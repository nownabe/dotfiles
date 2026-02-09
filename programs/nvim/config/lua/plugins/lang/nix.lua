-- Nix language support
-- nil_ls, statix, and deadnix are installed via Nix (home.nix)

return {
  {
    "AstroNvim/astrolsp",
    optional = true,
    opts = function(_, opts)
      opts.servers = require("astrocore").list_insert_unique(opts.servers or {}, { "nil_ls" })
      opts.config = vim.tbl_deep_extend("force", opts.config or {}, {
        nil_ls = {
          settings = {
            ["nil"] = {
              formatting = {
                command = { "nixfmt" },
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
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "nix" })
      end
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
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "nixfmt" })
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
