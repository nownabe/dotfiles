return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {
          -- Disable default mappings (astrocore / snacks.nvim)
          ["<Leader>ld"] = false,
          ["<Leader>lD"] = false,
          ["<Leader>lk"] = false,
          ["<Leader>ls"] = false,
          ["<Leader>lS"] = false,

          -- Disable default buffer mappings
          ["<Leader>bC"] = false,
          ["<Leader>bp"] = false,
          ["<Leader>br"] = false,
          ["<Leader>bs"] = false,
          ["<Leader>bse"] = false,
          ["<Leader>bsi"] = false,
          ["<Leader>bsm"] = false,
          ["<Leader>bsp"] = false,
          ["<Leader>bsr"] = false,
          ["<Leader>c"] = false,
          ["<Leader>C"] = false,

          -- Disable default g* LSP mappings
          ["gD"] = false,
          ["gd"] = false,
          ["gI"] = false,
          ["gra"] = false,
          ["gri"] = false,
          ["grn"] = false,
          ["grr"] = false,
          ["grt"] = false,
          ["gy"] = false,
          ["K"] = false,

          -- Buffer management (overrides default <Leader>bc and <Leader>bl)
          ["<Leader>bh"] = {
            function() require("astrocore.buffer").nav(-vim.v.count1) end,
            desc = "󰜲 Previous buffer",
          },
          ["<Leader>bl"] = {
            function() require("astrocore.buffer").nav(vim.v.count1) end,
            desc = "󰜵 Next buffer",
          },
          ["<Leader>bc"] = {
            function() require("astrocore.buffer").close() end,
            desc = "󰅖 Close current buffer",
          },

          -- Cursor navigation (overrides default <Leader>h and <Leader>l)
          ["<Leader>h"] = { "^", desc = "󰜲 Move to first non-whitespace" },
          ["<Leader>l"] = { "$", desc = "󰜵 Move to end of line" },
          ["<Leader>m"] = { "%", desc = "󰅪 Match nearest [], (), {}" },

          -- Diagnostics
          ["<Leader>;n"] = {
            function() vim.diagnostic.open_float() end,
            desc = "Hover diagnostics",
          },
          ["<Leader>;N"] = {
            function() Snacks.picker.diagnostics() end,
            desc = "Search diagnostics",
          },
        },
        v = {
          ["<Leader>la"] = false,
        },
      },
    },
  },
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      mappings = {
        n = {
          -- Disable default Language Tools group (astrolsp)
          ["<Leader>l"] = false,
          ["<Leader>la"] = false,
          ["<Leader>lA"] = false,
          ["<Leader>lf"] = false,
          ["<Leader>lG"] = false,
          ["<Leader>lh"] = false,
          ["<Leader>ll"] = false,
          ["<Leader>lL"] = false,
          ["<Leader>lr"] = false,
          ["<Leader>lR"] = false,
          ["<Leader>li"] = false,
          ["<Leader>lI"] = false,

          -- Language Tools group
          ["<Leader>;"] = { desc = " Language Tools" },

          -- LSP actions
          ["<Leader>;a"] = {
            function() vim.lsp.buf.code_action() end,
            desc = "Code action",
            cond = "textDocument/codeAction",
          },
          ["<Leader>;A"] = {
            function() vim.lsp.buf.code_action { context = { only = { "source" }, diagnostics = {} } } end,
            desc = "Source action",
            cond = "textDocument/codeAction",
          },

          -- Navigation
          ["<Leader>;d"] = {
            function() vim.lsp.buf.definition() end,
            desc = "Definition",
            cond = "textDocument/definition",
          },
          ["<Leader>;D"] = {
            function() vim.lsp.buf.declaration() end,
            desc = "Declaration",
            cond = "textDocument/declaration",
          },
          ["<Leader>;t"] = {
            function() vim.lsp.buf.type_definition() end,
            desc = "Type definition",
            cond = "textDocument/typeDefinition",
          },
          ["<Leader>;i"] = {
            function() Snacks.picker.lsp_implementations() end,
            desc = "Implementations",
          },
          ["<Leader>;r"] = {
            function() Snacks.picker.lsp_references() end,
            desc = "References",
          },

          -- Info
          ["<Leader>;h"] = {
            function() vim.lsp.buf.hover() end,
            desc = "Hover",
            cond = "textDocument/hover",
          },
          ["<Leader>;s"] = {
            function() vim.lsp.buf.signature_help() end,
            desc = "Signature help",
            cond = "textDocument/signatureHelp",
          },

          -- Refactoring
          ["<Leader>;R"] = {
            function() vim.lsp.buf.rename() end,
            desc = "Rename symbol",
            cond = "textDocument/rename",
          },
          ["<Leader>;f"] = {
            function() vim.lsp.buf.format(require("astrolsp").format_opts) end,
            desc = "Format buffer",
            cond = "textDocument/formatting",
          },

          -- CodeLens
          ["<Leader>;L"] = {
            function() vim.lsp.codelens.refresh() end,
            desc = "CodeLens refresh",
            cond = "textDocument/codeLens",
          },
          ["<Leader>;l"] = {
            function() vim.lsp.codelens.run() end,
            desc = "CodeLens run",
            cond = "textDocument/codeLens",
          },

          -- Search
          ["<Leader>;S"] = {
            function() Snacks.picker.lsp_workspace_symbols() end,
            desc = "Workspace symbols",
          },
          ["<Leader>;o"] = {
            function() require("aerial").toggle() end,
            desc = "Symbols outline",
          },

          -- Toggles
          ["<Leader>uf"] = {
            function() require("astrolsp.toggles").buffer_autoformat() end,
            desc = "Toggle autoformat (buffer)",
            cond = "textDocument/formatting",
          },
          ["<Leader>uF"] = {
            function() require("astrolsp.toggles").autoformat() end,
            desc = "Toggle autoformat (global)",
            cond = "textDocument/formatting",
          },
          ["<Leader>u?"] = {
            function() require("astrolsp.toggles").signature_help() end,
            desc = "Toggle signature help",
            cond = "textDocument/signatureHelp",
          },
          ["<Leader>uh"] = {
            function() require("astrolsp.toggles").buffer_inlay_hints() end,
            desc = "Toggle inlay hints (buffer)",
            cond = vim.lsp.inlay_hint and "textDocument/inlayHint" or false,
          },
          ["<Leader>uH"] = {
            function() require("astrolsp.toggles").inlay_hints() end,
            desc = "Toggle inlay hints (global)",
            cond = vim.lsp.inlay_hint and "textDocument/inlayHint" or false,
          },
          ["<Leader>uL"] = {
            function() require("astrolsp.toggles").codelens() end,
            desc = "Toggle CodeLens",
            cond = "textDocument/codeLens",
          },
          ["<Leader>uY"] = {
            function() require("astrolsp.toggles").buffer_semantic_tokens() end,
            desc = "Toggle semantic highlight (buffer)",
            cond = function(client)
              return client.supports_method "textDocument/semanticTokens/full" and vim.lsp.semantic_tokens
            end,
          },
        },
        v = {
          ["<Leader>l"] = false,
          ["<Leader>lf"] = false,

          ["<Leader>;"] = { desc = " Language Tools" },
          ["<Leader>;a"] = {
            function() vim.lsp.buf.code_action() end,
            desc = "Code action",
            cond = "textDocument/codeAction",
          },
          ["<Leader>;f"] = {
            function() vim.lsp.buf.format(require("astrolsp").format_opts) end,
            desc = "Format buffer",
            cond = "textDocument/rangeFormatting",
          },
        },
        x = {
          ["<Leader>la"] = false,

          ["<Leader>;a"] = {
            function() vim.lsp.buf.code_action() end,
            desc = "Code action",
            cond = "textDocument/codeAction",
          },
        },
      },
    },
  },
}
