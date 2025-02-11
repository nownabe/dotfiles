-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    options = {
      opt = {
        wrap = true,
      },
    },

    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- mappings seen under group name "Buffer"
        ["<Leader>bh"] = {
          function() require("astrocore.buffer").nav(-vim.v.count1) end,
          desc = "Previous buffer",
        },
        ["<Leader>bl"] = {
          function() require("astrocore.buffer").nav(vim.v.count1) end,
          desc = "Next buffer",
        },
        ["<Leader>bc"] = {
          function() require("astrocore.buffer").close() end,
          desc = "Close current buffer"
        },
        ["<Leader>br"] = false,
        ["<Leader>bp"] = false,
      },
    },
  },
}
