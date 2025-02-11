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
        panel = {
          -- enabled = true,
          enabled = false,
          auto_refresh = false,
          keymap = {
            jump_prev = "[[",
            jump_next = "]]",
            accept    = "<CR>",
            refresh   = "gr",
            open      = "<M-CR>",
          },
          layout = {
            position = "bottom",
            ratio = 0.4,
          },
        },
        copilot_node_command = "node",
        server_opts_overrides = {},
      })
    end,
  },
}

