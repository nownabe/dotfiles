return {
  "folke/sidekick.nvim",
  dependencies = { "copilotlsp-nvim/copilot-lsp" },
  event = "LspAttach",
  opts = {},
  -- stylua: ignore
  keys = {
    {
      "<tab>",
      function()
        if require("sidekick").nes_jump_or_apply() then
          return
        end
        return "<tab>"
      end,
      mode = { "i", "n" },
      expr = true,
      desc = "Goto/Apply Next Edit Suggestion",
    },
    {
      "<leader>aa",
      function() require("sidekick.cli").toggle() end,
      mode = { "n", "v" },
      desc = "Sidekick Toggle CLI",
    },
    {
      "<leader>as",
      function() require("sidekick.cli").select() end,
      desc = "Sidekick Select CLI",
    },
    {
      "<leader>at",
      function() require("sidekick.cli").send({ msg = "{this}" }) end,
      mode = { "x", "n" },
      desc = "Send This",
    },
    {
      "<leader>af",
      function() require("sidekick.cli").send({ msg = "{file}" }) end,
      desc = "Send File",
    },
    {
      "<leader>as",
      function() require("sidekick.cli").send({ msg = "{selection}" }) end,
      mode = { "x" },
      desc = "Send Visual Selection",
    },
    {
      "<leader>ap",
      function() require("sidekick.cli").prompt() end,
      mode = { "n", "v" },
      desc = "Sidekick Select Prompt",
    },
  },
}
