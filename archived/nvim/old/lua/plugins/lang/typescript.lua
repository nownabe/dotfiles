-- TypeScript/JavaScript Language Support
return {
  -- Extend treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "typescript", "tsx", "javascript" })
    end,
  },

  -- Extend mason-lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "ts_ls", "eslint" })
    end,
  },

  -- LSP configuration for ts_ls
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local lsp_utils = require("utils.lsp")
      opts.servers = opts.servers or {}
      opts.servers.ts_ls = {
        on_attach = function(client, bufnr)
          -- Disable tsserver formatting in favor of prettier
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
          lsp_utils.on_attach(client, bufnr)
        end,
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
        },
      }
    end,
  },

  -- TypeScript tools
  {
    "pmizio/typescript-tools.nvim",
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {},
  },

  -- Package info for package.json
  {
    "vuki656/package-info.nvim",
    event = { "BufRead package.json" },
    dependencies = "MunifTanjim/nui.nvim",
    opts = {},
  },
}
