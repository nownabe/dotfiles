-- LSP Configuration
return {
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "folke/neoconf.nvim",
    },
    config = function()
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

      -- Setup mason-lspconfig
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "gopls",
          "pyright",
          "rust_analyzer",
          "ts_ls",
          "html",
          "cssls",
          "jsonls",
          "yamlls",
          "marksman",
          "bashls",
          "dockerls",
          "terraformls",
          "taplo",
          "bufls",
          "ruby_ls",
          "solargraph",
          "astro",
          "tailwindcss",
        },
        automatic_installation = true,
      })

      -- Capabilities for autocompletion
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

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

      -- On attach function for keymaps
      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, silent = true }

        -- LSP keymaps under <Leader>;
        vim.keymap.set("n", "<Leader>;d", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
        vim.keymap.set("n", "<Leader>;D", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
        vim.keymap.set("n", "<Leader>;i", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
        vim.keymap.set("n", "<Leader>;t", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Go to type definition" }))
        vim.keymap.set("n", "<Leader>;R", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Show references" }))
        vim.keymap.set("n", "<Leader>;r", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
        vim.keymap.set("n", "<Leader>;h", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
        vim.keymap.set("n", "<Leader>;s", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature help" }))
        vim.keymap.set({ "n", "v" }, "<Leader>;a", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
        vim.keymap.set("n", "<Leader>;f", function()
          vim.lsp.buf.format({ async = true })
        end, vim.tbl_extend("force", opts, { desc = "Format buffer" }))

        -- Diagnostic keymaps
        vim.keymap.set("n", "<Leader>;n", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Show diagnostic" }))
        vim.keymap.set("n", "<Leader>;N", vim.diagnostic.setloclist, vim.tbl_extend("force", opts, { desc = "Diagnostics list" }))
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))

        -- Additional useful keymaps
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
        vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "References" }))
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
        vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))

        -- Enable inlay hints if supported
        if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
          pcall(vim.lsp.inlay_hint.enable, bufnr, true)
        end

        -- Enable code lens if supported
        if client.server_capabilities.codeLensProvider then
          local group = vim.api.nvim_create_augroup("LspCodeLens_" .. bufnr, { clear = true })
          vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
            buffer = bufnr,
            group = group,
            callback = function()
              vim.schedule(function()
                pcall(vim.lsp.codelens.refresh)
              end)
            end,
          })
          -- Trigger codelens refresh on attach
          vim.schedule(function()
            pcall(vim.lsp.codelens.refresh)
          end)
        end
      end

      -- Setup handlers with mason-lspconfig
      require("mason-lspconfig").setup_handlers({
        -- Default handler
        function(server_name)
          require("lspconfig")[server_name].setup({
            capabilities = capabilities,
            on_attach = on_attach,
          })
        end,

        -- Specific server configurations
        ["lua_ls"] = function()
          require("lspconfig").lua_ls.setup({
            capabilities = capabilities,
            on_attach = on_attach,
            settings = {
              Lua = {
                runtime = {
                  version = "LuaJIT",
                },
                diagnostics = {
                  globals = { "vim" },
                },
                workspace = {
                  library = vim.api.nvim_get_runtime_file("", true),
                  checkThirdParty = false,
                },
                telemetry = {
                  enable = false,
                },
                hint = {
                  enable = true,
                },
              },
            },
          })
        end,

        ["jsonls"] = function()
          require("lspconfig").jsonls.setup({
            capabilities = capabilities,
            on_attach = on_attach,
            settings = {
              json = {
                schemas = require("schemastore").json.schemas(),
                validate = { enable = true },
              },
            },
          })
        end,

        ["yamlls"] = function()
          require("lspconfig").yamlls.setup({
            capabilities = capabilities,
            on_attach = on_attach,
            settings = {
              yaml = {
                schemaStore = {
                  enable = false,
                  url = "",
                },
                schemas = require("schemastore").yaml.schemas(),
              },
            },
          })
        end,

        ["gopls"] = function()
          require("lspconfig").gopls.setup({
            capabilities = capabilities,
            on_attach = on_attach,
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

        ["pyright"] = function()
          require("lspconfig").pyright.setup({
            capabilities = capabilities,
            on_attach = on_attach,
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

        ["ts_ls"] = function()
          require("lspconfig").ts_ls.setup({
            capabilities = capabilities,
            on_attach = function(client, bufnr)
              -- Disable tsserver formatting in favor of prettier
              client.server_capabilities.documentFormattingProvider = false
              client.server_capabilities.documentRangeFormattingProvider = false
              on_attach(client, bufnr)
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
          })
        end,

        ["tailwindcss"] = function()
          require("lspconfig").tailwindcss.setup({
            capabilities = capabilities,
            on_attach = on_attach,
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
          })
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

  -- Schema store for JSON/YAML
  {
    "b0o/schemastore.nvim",
    lazy = true,
  },

  -- Project-local LSP settings
  {
    "folke/neoconf.nvim",
    cmd = "Neoconf",
    opts = {},
  },

  -- Better Lua LSP for Neovim
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },

  -- Optional: lua types
  { "Bilal2453/luvit-meta", lazy = true },

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
