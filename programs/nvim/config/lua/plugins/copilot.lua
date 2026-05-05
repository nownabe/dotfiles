return {
  {
    "copilotlsp-nvim/copilot-lsp",
    config = function()
      -- Suppress copilot-lsp's automatic sign-in flow since copilot.vim
      -- handles authentication. The didChangeStatus handler's sign-in
      -- request is also incompatible with Neovim 0.12's stricter
      -- handler validation.
      local copilot_handlers = require("copilot-lsp.handlers")
      copilot_handlers.didChangeStatus = function() end

      vim.lsp.enable("copilot_ls")
    end,
  },
  -- TODO: Replace copilot.vim with copilot-lsp inline completion when Neovim v0.12 is released (vim.lsp.inline_completion)
  {
    "github/copilot.vim",
    lazy = false,
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
