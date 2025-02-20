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

          -- LSP
          ["<leader>;"] = { desc = get_icon("ActiveLSP", 1, true) .. "Language Tools" },
          ["<leader>;d"] = {
            function() require("telescope.builtin").lsp_definitions() end,
            desc = "Definition of current symbol",
          },

          -- TODO: Disable all <leader>lx
        },
      },
    },
  },
}
