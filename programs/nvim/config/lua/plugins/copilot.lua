return {
  {
    "copilotlsp-nvim/copilot-lsp",
    config = function()
      vim.lsp.enable("copilot_ls")

      -- Register signIn handler on copilot_ls client for Neovim 0.12 compat.
      -- copilot-lsp's sign_in() calls client:request("signIn", ..., nil, bufnr),
      -- which requires client.handlers["signIn"] to be set in Neovim 0.12+.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("copilot-lsp-handlers", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client.name == "copilot_ls" then
            client.handlers["signIn"] = require("copilot-lsp.handlers").signIn
          end
        end,
      })

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
