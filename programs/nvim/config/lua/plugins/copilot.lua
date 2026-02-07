return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  opts = {
    -- Disable copilot's own UI; sidekick.nvim handles NES
    suggestion = { enabled = false },
    panel = { enabled = false },
  },
}
