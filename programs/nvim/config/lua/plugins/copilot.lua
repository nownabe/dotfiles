return {
  {
    "copilotlsp-nvim/copilot-lsp",
    config = function()
      vim.lsp.config("copilot_ls", {
        on_init = function() end,
      })
      vim.lsp.enable("copilot_ls")
    end,
  },
  {
    -- https://github.com/AstroNvim/AstroNvim/blob/main/lua/astronvim/plugins/mason-tool-installer.lua
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "copilot-language-server",
      },
    },
  },
}
