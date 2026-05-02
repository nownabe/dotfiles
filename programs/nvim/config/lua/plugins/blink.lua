return {
  {
    "saghen/blink.cmp",
    dependencies = { "saghen/blink.lib" },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        ["<Tab>"] = {},
      },
    },
  },
  { "saghen/blink.lib", lazy = true },
}
