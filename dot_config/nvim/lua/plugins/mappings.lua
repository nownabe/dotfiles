-- ref. https://github.com/AstroNvim/AstroNvim/blob/1411df4d970e59f1b5721556a043c5c828daf5ad/lua/astronvim/plugins/_astrocore_mappings.lua

local astrocore = require "astrocore"
local get_icon = require("astroui").get_icon

return {
  {
    "AstroNvim/astrocore",
    ---@params opts AstroCoreOpts
    opts = function(_, opts)
      local maps = astrocore.empty_map_table()

      -- Sections
      maps.n["<Leader>a"] = { desc = "Avante" }
      maps.n["<Leader>c"] = { desc = "Copilot" }

      -- Cursor
      maps.n["<Leader>h"] = { "^", desc = "Move to first non-whitespace" }
      maps.n["<Leader>l"] = { "$", desc = "Move to the end of the line" }
      maps.n["<Leader>m"] = { "%", desc = "Match nearest [], (), {}" }

      -- LSP
      maps.n["<Leader>ld"] = false
      maps.n["<Leader>lD"] = false
      maps.n["<Leader>ls"] = false
      maps.n["<Leader>lS"] = false

      -- Telescope
      local telescope = require "telescope.builtin"
      maps.n["<Leader>ff"] = { function() telescope.find_files { hidden = true } end, desc = "Find all files" }
      maps.n["<Leader>fF"] = { function() telescope.find_files { hidden = true } end, desc = "Find files" }
      maps.n["<Leader>fg"] = { function() telescope.live_grep { hidden = true } end, desc = "Live grep" }
      maps.n["<Leader>fG"] = { function() telescope.git_files() end, desc = "Find git files" }

      opts.mappings = astrocore.extend_tbl(opts.mappings, maps)
    end,
  },
  {
    -- ref. https://github.com/AstroNvim/AstroNvim/blob/87dc70f7761c3e9965315182f0c40bfbd2cbcd0e/lua/astronvim/plugins/_astrolsp_mappings.lua
    "AstroNvim/astrolsp",
    ---@param opts AstroLSPOpts
    opts = function(_, opts)
      local maps = astrocore.empty_map_table()

      maps.n["<Leader>;"] = { desc = get_icon("ActiveLSP", 1, true) .. "Language Tools" }
      maps.v["<Leader>;"] = { desc = get_icon("ActiveLSP", 1, true) .. "Language Tools" }

      maps.n["<Leader>;a"] = {
        function() vim.lsp.buf.code_action() end,
        desc = "LSP code action",
        cond = "textDocument/codeAction",
      }
      maps.x["<Leader>;a"] = {
        function() vim.lsp.buf.code_action() end,
        desc = "LSP code action",
        cond = "textDocument/codeAction",
      }
      maps.n["<Leader>;A"] = {
        function() vim.lsp.buf.code_action { context = { only = { "source" }, diagnostics = {} } } end,
        desc = "LSP source action",
        cond = "textDocument/codeAction",
      }

      maps.n["<Leader>;l"] =
        { function() vim.lsp.codelens.refresh() end, desc = "LSP CodeLens refresh", cond = "textDocument/codeLens" }
      maps.n["<Leader>;L"] =
        { function() vim.lsp.codelens.run() end, desc = "LSP CodeLens run", cond = "textDocument/codeLens" }
      maps.n["<Leader>uL"] = {
        function() require("astrolsp.toggles").codelens() end,
        desc = "Toggle CodeLens",
        cond = "textDocument/codeLens",
      }

      maps.n["gD"] = false
      maps.n["gd"] = false
      maps.n["<Leader>;D"] = {
        function() vim.lsp.buf.declaration() end,
        desc = "Declaration of current symbol",
        cond = "textDocument/declaration",
      }
      maps.n["<Leader>;d"] = {
        function() vim.lsp.buf.definition() end,
        desc = "Show the definition of current symbol",
        cond = "textDocument/definition",
      }
      -- maps.n["<Leader>;d"] = {
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
      maps.n["<Leader>;f"] = {
        function() vim.lsp.buf.format(require("astrolsp").format_opts) end,
        desc = "Format buffer",
        cond = formatting_enabled,
      }
      maps.v["<Leader>;f"] = {
        function() vim.lsp.buf.format(require("astrolsp").format_opts) end,
        desc = "Format buffer",
        cond = formatting_checker "rangeFormatting",
      }
      maps.n["<Leader>uf"] = {
        function() require("astrolsp.toggles").buffer_autoformat() end,
        desc = "Toggle autoformatting (buffer)",
        cond = formatting_enabled,
      }
      maps.n["<Leader>uF"] = {
        function() require("astrolsp.toggles").autoformat() end,
        desc = "Toggle autoformatting (global)",
        cond = formatting_enabled,
      }

      maps.n["<Leader>u?"] = {
        function() require("astrolsp.toggles").signature_help() end,
        desc = "Toggle automatic signature help",
        cond = "textDocument/signatureHelp",
      }

      maps.n["gI"] = false
      -- maps.n["<Leader>;i"] = {
      --   function() vim.lsp.buf.implementation() end,
      --   desc = "Implementation of current symbol",
      --   cond = "textDocument/implementation",
      -- }
      maps.n["<Leader>;i"] = {
        function() require("telescope.builtin").lsp_implementations() end,
        desc = "Implementation of current symbol",
      }

      maps.n["<Leader>uh"] = {
        function() require("astrolsp.toggles").buffer_inlay_hints() end,
        desc = "Toggle LSP inlay hints (buffer)",
        cond = vim.lsp.inlay_hint and "textDocument/inlayHint" or false,
      }
      maps.n["<Leader>uH"] = {
        function() require("astrolsp.toggles").inlay_hints() end,
        desc = "Toggle LSP inlay hints (global)",
        cond = vim.lsp.inlay_hint and "textDocument/inlayHint" or false,
      }

      -- maps.n["<Leader>;R"] =
      --   { function() vim.lsp.buf.references() end, desc = "Search references", cond = "textDocument/references" }
      maps.n["<Leader>;R"] = {
        function() require("telescope.builtin").lsp_references() end,
        desc = "Search references",
      }

      maps.n["<Leader>;r"] = {
        function() vim.lsp.buf.rename() end,
        desc = "Rename current symbol",
        cond = "textDocument/rename",
      }

      maps.n["<Leader>;s"] = {
        function() vim.lsp.buf.signature_help() end,
        desc = "Signature help",
        cond = "textDocument/signatureHelp",
      }

      maps.n["<Leader>;h"] = {
        function() vim.lsp.buf.hover() end,
        desc = "Hover symbol details",
        cond = "textDocument/hover",
      }

      maps.n["<Leader>;t"] = {
        function() vim.lsp.buf.type_definition() end,
        desc = "Definition of current type",
        cond = "textDocument/typeDefinition",
      }
      maps.n["gy"] = false

      -- maps.n["<Leader>;S"] = {
      --   function() vim.lsp.buf.workspace_symbol() end,
      --   desc = "Search workspace symbols",
      --   cond = "workspace/symbol",
      -- }
      maps.n["<Leader>;S"] = {
        function() require("telescope.builtin").lsp_dynamic_workspace_symbols() end,
        desc = "Search workspace symbols",
      }

      maps.n["<Leader>;o"] = {
        function() require("aerial").toggle() end,
        desc = "Symbols outline",
      }

      maps.n["<Leader>uY"] = {
        function() require("astrolsp.toggles").buffer_semantic_tokens() end,
        desc = "Toggle LSP semantic highlight (buffer)",
        cond = function(client)
          return client.supports_method "textDocument/semanticTokens/full" and vim.lsp.semantic_tokens
        end,
      }

      maps.n["<Leader>;n"] = {
        function() vim.diagnostic.open_float() end,
        desc = "Hover diagnostics",
      }
      maps.n["<Leader>;N"] = {
        function() require("telescope.builtin").diagnostics() end,
        desc = "Search diagnostics",
      }

      opts.mappings = maps
    end,
  },
}
