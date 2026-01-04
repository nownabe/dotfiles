-- Go Language Support
return {
  -- Extend treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "go", "gomod", "gosum", "gowork" })
    end,
  },

  -- Extend mason-lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "gopls" })
    end,
  },

  -- LSP configuration for gopls
  {
    "neovim/nvim-lspconfig",
    opts = {},
    config = function()
      local lsp_utils = require("utils.lsp")
      require("lspconfig").gopls.setup({
        capabilities = lsp_utils.get_capabilities(),
        on_attach = lsp_utils.on_attach,
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
            gofumpt = true,
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      })
    end,
  },

  -- Go development tools
  {
    "olexsmir/gopher.nvim",
    ft = "go",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {},
    keys = {
      { "<leader>gsj", "<cmd>GoTagAdd json<cr>", desc = "Add json tags" },
      { "<leader>gsy", "<cmd>GoTagAdd yaml<cr>", desc = "Add yaml tags" },
      { "<leader>gsi", "<cmd>GoIfErr<cr>", desc = "Add if err" },
    },
  },

  -- DAP for Go
  {
    "leoluz/nvim-dap-go",
    ft = "go",
    dependencies = "mfussenegger/nvim-dap",
    config = function()
      require("dap-go").setup()
    end,
  },
}
