return {
  {
    "copilotlsp-nvim/copilot-lsp",
    config = function()
      -- Neovim 0.12 compat: patch copilot-lsp's didChangeStatus to pass
      -- the signIn handler explicitly to client:request(), since Neovim 0.12
      -- requires client.handlers[method] to be set when handler arg is nil.
      local copilot_handlers = require("copilot-lsp.handlers")
      local original_didChangeStatus = copilot_handlers.didChangeStatus
      copilot_handlers.didChangeStatus = function(err, res, ctx)
        if not err and res.kind == "Error" and res.message:find("not signed into") then
          local client = vim.lsp.get_client_by_id(ctx.client_id)
          if client then
            client.handlers["signIn"] = copilot_handlers.signIn
          end
        end
        original_didChangeStatus(err, res, ctx)
      end

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
            client.handlers.didChangeStatus = function(err2, res2, ctx2)
              copilot_handlers.didChangeStatus(err2, res2, ctx2)
              sidekick_handler(err2, res2, ctx2)
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
