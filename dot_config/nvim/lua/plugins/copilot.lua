return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = false,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = "<Tab>",
            prev   = "<M-[>",
            next   = "<M-]>",
            dismiss = "<C-]>",
          },
        },
        panel = { enabled = false },
        copilot_node_command = "node",
        server_opts_overrides = {},
      })
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function ()
      require("copilot_cmp").setup()
    end,
  }
}

