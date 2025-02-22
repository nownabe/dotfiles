-- ref. https://github.com/AstroNvim/AstroNvim/blob/1411df4d970e59f1b5721556a043c5c828daf5ad/lua/astronvim/plugins/_astrocore_mappings.lua

local astrocore = require "astrocore"
local get_icon = require("astroui").get_icon

return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {
          -- Cursor
          ["<leader>h"] = { "^", desc = "Move to first non-whitespace" },
          ["<leader>l"] = { "$", desc = "Move to the end of the line" },
          ["<leader>m"] = { "%", desc = "Match nearest [], (), {}" },
        },
      },
    },
  },
  {
    -- ref. https://github.com/AstroNvim/AstroNvim/blob/87dc70f7761c3e9965315182f0c40bfbd2cbcd0e/lua/astronvim/plugins/_astrolsp_mappings.lua
    "AstroNvim/astrolsp",
    ---@param opts AstroLSPOpts
    opts = function(_, opts)
      local maps = astrocore.empty_map_table()

      maps.n["<leader>;"] = { desc = get_icon("ActiveLSP", 1, true) .. "Language Tools" }
      maps.v["<leader>;"] = { desc = get_icon("ActiveLSP", 1, true) .. "Language Tools" }

      maps.n["<leader>;a"] = {
        function() vim.lsp.buf.code_action() end,
        desc = "LSP code action",
        cond = "textDocument/codeAction",
      }
      maps.x["<leader>;a"] = {
        function() vim.lsp.buf.code_action() end,
        desc = "LSP code action",
        cond = "textDocument/codeAction",
      }
      maps.n["<leader>;A"] = {
        function() vim.lsp.buf.code_action { context = { only = { "source" }, diagnostics = {} } } end,
        desc = "LSP source action",
        cond = "textDocument/codeAction",
      }

      maps.n["<leader>;l"] =
        { function() vim.lsp.codelens.refresh() end, desc = "LSP CodeLens refresh", cond = "textDocument/codeLens" }
      maps.n["<leader>;L"] =
        { function() vim.lsp.codelens.run() end, desc = "LSP CodeLens run", cond = "textDocument/codeLens" }
      maps.n["<leader>uL"] = {
        function() require("astrolsp.toggles").codelens() end,
        desc = "Toggle CodeLens",
        cond = "textDocument/codeLens",
      }

      maps.n["gD"] = false
      maps.n["gd"] = false
      maps.n["<leader>;D"] = {
        function() vim.lsp.buf.declaration() end,
        desc = "Declaration of current symbol",
        cond = "textDocument/declaration",
      }
      maps.n["<leader>;d"] = {
        function() vim.lsp.buf.definition() end,
        desc = "Show the definition of current symbol",
        cond = "textDocument/definition",
      }
      -- maps.n["<leader>;d"] = {
      --   function() require("telescope.builtin").lsp_definitions() end,
      --   desc = "Definition of current symbol",
      -- },

      local function formatting_checker(method)
        method = "textDocument/" .. (method or "formatting")
        return function(client)
          local disabled = opts.formatting.disabled
          return client.supports_method(method) and disabled ~= true and not vim.tbl_contains(disabled, client.name)
        end
      end
      local formatting_enabled = formatting_checker()
      maps.n["<leader>;f"] = {
        function() vim.lsp.buf.format(require("astrolsp").format_opts) end,
        desc = "Format buffer",
        cond = formatting_enabled,
      }
      maps.v["<leader>;f"] = {
        function() vim.lsp.buf.format(require("astrolsp").format_opts) end,
        desc = "Format buffer",
        cond = formatting_checker "rangeFormatting",
      }
      maps.n["<leader>uf"] = {
        function() require("astrolsp.toggles").buffer_autoformat() end,
        desc = "Toggle autoformatting (buffer)",
        cond = formatting_enabled,
      }
      maps.n["<leader>uF"] = {
        function() require("astrolsp.toggles").autoformat() end,
        desc = "Toggle autoformatting (global)",
        cond = formatting_enabled,
      }

      maps.n["<leader>u?"] = {
        function() require("astrolsp.toggles").signature_help() end,
        desc = "Toggle automatic signature help",
        cond = "textDocument/signatureHelp",
      }

      maps.n["gI"] = false
      -- maps.n["<leader>;i"] = {
      --   function() vim.lsp.buf.implementation() end,
      --   desc = "Implementation of current symbol",
      --   cond = "textDocument/implementation",
      -- }
      maps.n["<leader>;i"] = {
        function() require("telescope.builtin").lsp_implementations() end,
        desc = "Implementation of current symbol",
      }

      maps.n["<leader>uh"] = {
        function() require("astrolsp.toggles").buffer_inlay_hints() end,
        desc = "Toggle LSP inlay hints (buffer)",
        cond = vim.lsp.inlay_hint and "textDocument/inlayHint" or false,
      }
      maps.n["<leader>uH"] = {
        function() require("astrolsp.toggles").inlay_hints() end,
        desc = "Toggle LSP inlay hints (global)",
        cond = vim.lsp.inlay_hint and "textDocument/inlayHint" or false,
      }

      -- maps.n["<leader>;R"] =
      --   { function() vim.lsp.buf.references() end, desc = "Search references", cond = "textDocument/references" }
      maps.n["<leader>;R"] = {
        function() require("telescope.builtin").lsp_references() end,
        desc = "Search references",
      }

      maps.n["<leader>;r"] = {
        function() vim.lsp.buf.rename() end,
        desc = "Rename current symbol",
        cond = "textDocument/rename",
      }

      maps.n["<leader>;s"] = {
        function() vim.lsp.buf.signature_help() end,
        desc = "Signature help",
        cond = "textDocument/signatureHelp",
      }

      maps.n["<leader>;h"] = {
        function() vim.lsp.buf.hover() end,
        desc = "Hover symbol details",
        cond = "textDocument/hover",
      }

      maps.n["<leader>;t"] = {
        function() vim.lsp.buf.type_definition() end,
        desc = "Definition of current type",
        cond = "textDocument/typeDefinition",
      }
      maps.n["gy"] = false

      -- maps.n["<leader>;S"] = {
      --   function() vim.lsp.buf.workspace_symbol() end,
      --   desc = "Search workspace symbols",
      --   cond = "workspace/symbol",
      -- }
      maps.n["<leader>;S"] = {
        function() require("telescope.builtin").lsp_dynamic_workspace_symbols() end,
        desc = "Search workspace symbols",
      }

      maps.n["<leader>uY"] = {
        function() require("astrolsp.toggles").buffer_semantic_tokens() end,
        desc = "Toggle LSP semantic highlight (buffer)",
        cond = function(client)
          return client.supports_method "textDocument/semanticTokens/full" and vim.lsp.semantic_tokens
        end,
      }

      maps.n["<leader>;n"] = {
        function() vim.diagnostic.open_float() end,
        desc = "Hover diagnostics",
      }
      maps.n["<leader>;N"] = {
        function() require("telescope.builtin").diagnostics() end,
        desc = "Search diagnostics",
      }

      opts.mappings = astrocore.extend_tbl(opts.mappings, maps)
    end,
  },
}
