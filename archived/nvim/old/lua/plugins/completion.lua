-- Completion Configuration
return {
  {
    "saghen/blink.cmp",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    version = "1.*",
    opts = {
      keymap = { preset = "default" },
      appearance = {
        nerd_font_variant = "mono",
      },
      completion = {
        documentation = { auto_show = true },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
    },
    opts_extend = { "sources.default" },
  },

  -- LuaSnip - Snippet engine
  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    lazy = true,
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
  },

  -- Friendly snippets
  {
    "rafamadriz/friendly-snippets",
    lazy = true,
  },
}
