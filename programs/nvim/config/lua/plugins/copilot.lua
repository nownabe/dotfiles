return {
  {
    "copilotlsp-nvim/copilot-lsp",
    config = function()
      vim.lsp.enable("copilot_ls")

      -- sidekick.nvim overwrites the didChangeStatus handler, which breaks
      -- copilot-lsp's automatic sign-in flow. Re-attach the sign-in handler
      -- so that it fires alongside sidekick's status handler.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("copilot-lsp-signin", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client or client.name ~= "copilot_ls" then
            return
          end
          local copilot_handlers = require("copilot-lsp.handlers")
          local current = client.handlers.didChangeStatus
          if current and current ~= copilot_handlers.didChangeStatus then
            client.handlers.didChangeStatus = function(err, res, ctx)
              copilot_handlers.didChangeStatus(err, res, ctx)
              current(err, res, ctx)
            end
          end
        end,
      })
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
