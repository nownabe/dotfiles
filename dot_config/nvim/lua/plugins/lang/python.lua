-- Python Language Support
return {
  -- Extend treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "python" })
    end,
  },

  -- Extend mason-lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "pyright", "ruff_lsp" })
    end,
  },

  -- LSP configuration for pyright
  {
    "neovim/nvim-lspconfig",
    opts = {},
    config = function()
      local lsp_utils = require("utils.lsp")
      require("lspconfig").pyright.setup({
        capabilities = lsp_utils.get_capabilities(),
        on_attach = lsp_utils.on_attach,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "workspace",
              useLibraryCodeForTypes = true,
              typeCheckingMode = "basic",
            },
          },
        },
      })
    end,
  },

  -- DAP for Python
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = "mfussenegger/nvim-dap",
    config = function()
      require("dap-python").setup("python")
    end,
  },
}
