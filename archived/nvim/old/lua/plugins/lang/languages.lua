-- Consolidated Simple Language Support
-- This file contains basic language configurations that only require:
-- - Treesitter parser installation
-- - LSP server installation via mason-lspconfig
-- - Simple plugin additions without complex setup
--
-- Complex languages with custom plugins and configurations remain in separate files:
-- - lua.lua (lua_ls custom config, lazydev)
-- - go.lua (gopher.nvim, dap-go, custom keymaps, gopls config)
-- - python.lua (dap-python, pyright config)
-- - rust.lua (rustaceanvim, crates.nvim)
-- - typescript.lua (typescript-tools, package-info, ts_ls config)
-- - markdown.lua (render-markdown plugin)

-- Note: LSP server configurations for jsonls, yamlls, and tailwindcss are
-- defined in lua/plugins/lsp.lua using mason-lspconfig's setup_handlers

return {
  -- ============================================================================
  -- Treesitter Parser Installation
  -- ============================================================================
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "windwp/nvim-ts-autotag",
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        -- Shell/Bash
        "bash",
        -- Docker
        "dockerfile",
        -- HTML/CSS
        "html",
        "css",
        "scss",
        -- Data formats
        "json",
        "jsonc",
        "json5",
        "yaml",
        "toml",
        "xml",
        -- Infrastructure
        "terraform",
        "hcl",
        -- Web frameworks
        "astro",
        -- Protocol Buffers
        "proto",
        -- MDX
        "mdx",
        -- Ruby
        "ruby",
      })

      -- Auto tag configuration for HTML/JSX/Vue/etc
      opts.autotag = {
        enable = true,
        enable_rename = true,
        enable_close = true,
        enable_close_on_slash = true,
      }
    end,
  },

  -- ============================================================================
  -- LSP Server Installation via Mason
  -- ============================================================================
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        -- Shell/Bash
        "bashls",
        -- Docker
        "dockerls",
        "docker_compose_language_service",
        -- HTML/CSS
        "html",
        "cssls",
        "emmet_ls",
        "tailwindcss",
        -- Data formats
        "jsonls",
        "yamlls",
        "taplo", -- TOML
        -- Infrastructure
        "terraformls",
        "tflint",
        -- Web frameworks
        "astro",
        -- Ruby
        "solargraph",
      })
    end,
  },

  -- ============================================================================
  -- LSP Configurations with Custom Settings
  -- ============================================================================

  -- LSP configuration for jsonls
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.jsonls = {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      }
    end,
  },

  -- LSP configuration for yamlls
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.yamlls = {
        settings = {
          yaml = {
            schemaStore = {
              enable = false,
              url = "",
            },
            schemas = require("schemastore").yaml.schemas(),
          },
        },
      }
    end,
  },

  -- LSP configuration for tailwindcss
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.tailwindcss = {
        settings = {
          tailwindCSS = {
            experimental = {
              classRegex = {
                { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
              },
            },
          },
        },
      }
    end,
  },

  -- ============================================================================
  -- Simple Plugin-Based Language Support
  -- ============================================================================

  -- Chezmoi support
  {
    "alker0/chezmoi.vim",
    lazy = false,
    init = function()
      vim.g["chezmoi#use_tmp_buffer"] = true
    end,
  },

  -- CUE language support
  {
    "jjo/vim-cue",
    ft = "cue",
  },

  -- Rego (Open Policy Agent) support
  {
    "tsandall/vim-rego",
    ft = "rego",
  },

  -- ============================================================================
  -- Schema Store for JSON/YAML
  -- ============================================================================
  {
    "b0o/schemastore.nvim",
    lazy = true,
  },
}
