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
