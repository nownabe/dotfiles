-- LSP Configuration
return {
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      servers = {},
      setup = {},
    },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "folke/neoconf.nvim",
    },
    config = function(_, opts)
      -- Setup neoconf first for project-local settings
      require("neoconf").setup({})

      -- Setup mason
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })

      local lsp_utils = require("utils.lsp")
      local capabilities = lsp_utils.get_capabilities()
      local servers = opts.servers or {}
      local setup = opts.setup or {}

      -- Setup mason-lspconfig
      -- Language-specific LSP servers are managed in lua/plugins/lang/*.lua
      require("mason-lspconfig").setup({
        ensure_installed = {},
        automatic_installation = true,
      })

      -- Define diagnostic signs
      local signs = {
        { name = "DiagnosticSignError", text = " " },
        { name = "DiagnosticSignWarn", text = " " },
        { name = "DiagnosticSignHint", text = " " },
        { name = "DiagnosticSignInfo", text = " " },
      }
      for _, sign in ipairs(signs) do
        vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
      end

      -- Diagnostic configuration
      vim.diagnostic.config({
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        severity_sort = true,
        signs = true,
        float = {
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })

      -- Setup handlers with mason-lspconfig and per-language options from opts.servers
      -- Language-specific options are populated in lua/plugins/lang/*.lua
      require("mason-lspconfig").setup_handlers({
        function(server_name)
          local server_opts = servers[server_name] or {}
          server_opts.capabilities = server_opts.capabilities or capabilities
          server_opts.on_attach = server_opts.on_attach or lsp_utils.on_attach

          if setup[server_name] then
            if setup[server_name](server_name, server_opts) then
              return
            end
          elseif setup["*"] then
            if setup["*"](server_name, server_opts) then
              return
            end
          end

          require("lspconfig")[server_name].setup(server_opts)
        end,
      })
    end,
  },

  -- Mason - LSP installer
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall", "MasonUninstallAll", "MasonLog" },
    build = ":MasonUpdate",
    opts = {},
  },

  -- Mason lspconfig bridge
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = true,
  },

  -- Project-local LSP settings
  {
    "folke/neoconf.nvim",
    cmd = "Neoconf",
    opts = {},
  },

  -- LSP signature help
  {
    "ray-x/lsp_signature.nvim",
    event = "LspAttach",
    opts = {
      bind = true,
      handler_opts = {
        border = "rounded",
      },
      hint_enable = false,
    },
  },

  -- Symbol outline
  {
    "stevearc/aerial.nvim",
    cmd = "AerialToggle",
    keys = {
      { "<leader>lo", "<cmd>AerialToggle<cr>", desc = "Toggle symbols outline" },
    },
    opts = {
      backends = { "treesitter", "lsp", "markdown", "man" },
      layout = {
        min_width = 30,
      },
      attach_mode = "global",
      filter_kind = false,
      show_guides = true,
    },
  },

  -- LSP kind icons for completion menu
  {
    "onsails/lspkind.nvim",
    lazy = true,
  },

  -- File operations with LSP support
  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-neo-tree/neo-tree.nvim" },
    event = "LspAttach",
    opts = {},
  },
}
