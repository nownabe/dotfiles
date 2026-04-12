return {
  {
    "copilotlsp-nvim/copilot-lsp",
    config = function()
      vim.lsp.enable("copilot_ls")

      -- sidekick.nvim overwrites the copilot_ls didChangeStatus handler,
      -- which breaks copilot-lsp's automatic sign-in flow. Patch
      -- sidekick's attach to chain copilot-lsp's sign-in handler.
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyLoad",
        group = vim.api.nvim_create_augroup("copilot-lsp-signin", { clear = true }),
        callback = function(ev)
          if ev.data ~= "sidekick.nvim" then
            return
          end
          local sk_status = require("sidekick.status")
          local original_attach = sk_status.attach
          sk_status.attach = function(client)
            original_attach(client)
            local sidekick_handler = client.handlers.didChangeStatus
            client.handlers.didChangeStatus = function(err, res, ctx)
              require("copilot-lsp.handlers").didChangeStatus(err, res, ctx)
              sidekick_handler(err, res, ctx)
            end
          end
          return true -- remove autocmd
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
