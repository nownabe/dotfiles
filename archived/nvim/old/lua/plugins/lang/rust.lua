-- Rust Language Support
return {
  -- Extend treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "rust" })
    end,
  },

  -- Rustaceanvim (replaces rust-tools)
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    lazy = false,
    ft = { "rust" },
    config = function()
      vim.g.rustaceanvim = {
        server = {
          on_attach = function(client, bufnr)
            -- Use the same keymaps as other LSP servers
          end,
          -- capabilities = require("cmp_nvim_lsp").default_capabilities(),
        },
      }
    end,
  },

  -- Crates.nvim - Cargo.toml helper
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      null_ls = {
        enabled = true,
        name = "crates.nvim",
      },
    },
  },
}
