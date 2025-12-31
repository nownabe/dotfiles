-- LSP Utility Functions
local M = {}

-- Toggle format on save
M.format_on_save_enabled = true

function M.toggle_format_on_save()
  M.format_on_save_enabled = not M.format_on_save_enabled
  local utils = require("utils")
  utils.notify(
    "Format on save " .. (M.format_on_save_enabled and "enabled" or "disabled"),
    vim.log.levels.INFO
  )
end

-- Toggle inlay hints
function M.toggle_inlay_hints()
  if vim.lsp.inlay_hint then
    local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
    vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
    local utils = require("utils")
    utils.notify(
      "Inlay hints " .. (not enabled and "enabled" or "disabled"),
      vim.log.levels.INFO
    )
  else
    local utils = require("utils")
    utils.notify("Inlay hints not supported", vim.log.levels.WARN)
  end
end

-- Toggle codelens
M.codelens_enabled = true

function M.toggle_codelens()
  M.codelens_enabled = not M.codelens_enabled
  if M.codelens_enabled then
    vim.lsp.codelens.refresh()
  else
    vim.lsp.codelens.clear()
  end
  local utils = require("utils")
  utils.notify(
    "CodeLens " .. (M.codelens_enabled and "enabled" or "disabled"),
    vim.log.levels.INFO
  )
end

-- Toggle diagnostics
M.diagnostics_enabled = true

function M.toggle_diagnostics()
  M.diagnostics_enabled = not M.diagnostics_enabled
  if M.diagnostics_enabled then
    vim.diagnostic.enable()
  else
    vim.diagnostic.disable()
  end
  local utils = require("utils")
  utils.notify(
    "Diagnostics " .. (M.diagnostics_enabled and "enabled" or "disabled"),
    vim.log.levels.INFO
  )
end

-- Format buffer
function M.format_buffer(async)
  async = async == nil and false or async
  vim.lsp.buf.format({
    async = async,
    timeout_ms = 2000,
    filter = function(client)
      -- Filter out certain formatters if needed
      return client.name ~= "tsserver"
    end,
  })
end

return M
