-- LSP Utility Functions
local M = {}

-- Get default capabilities for LSP
function M.get_capabilities()
  return require("cmp_nvim_lsp").default_capabilities()
end

-- Common on_attach function for all LSP servers
function M.on_attach(client, bufnr)
  local opts = { buffer = bufnr, silent = true }

  -- LSP keymaps under <Leader>;
  vim.keymap.set("n", "<Leader>;d", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
  vim.keymap.set("n", "<Leader>;D", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
  vim.keymap.set("n", "<Leader>;i", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
  vim.keymap.set("n", "<Leader>;t", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Go to type definition" }))
  vim.keymap.set("n", "<Leader>;R", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Show references" }))
  vim.keymap.set("n", "<Leader>;r", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
  vim.keymap.set("n", "<Leader>;h", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
  vim.keymap.set("n", "<Leader>;s", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature help" }))
  vim.keymap.set({ "n", "v" }, "<Leader>;a", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
  vim.keymap.set("n", "<Leader>;f", function()
    vim.lsp.buf.format({ async = true })
  end, vim.tbl_extend("force", opts, { desc = "Format buffer" }))

  -- Diagnostic keymaps
  vim.keymap.set("n", "<Leader>;n", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Show diagnostic" }))
  vim.keymap.set("n", "<Leader>;N", vim.diagnostic.setloclist, vim.tbl_extend("force", opts, { desc = "Diagnostics list" }))
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))

  -- Additional useful keymaps
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
  vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "References" }))
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
  vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))

  -- Enable inlay hints if supported
  if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
    pcall(vim.lsp.inlay_hint.enable, bufnr, true)
  end

  -- Enable code lens if supported
  if client.server_capabilities.codeLensProvider then
    local group = vim.api.nvim_create_augroup("LspCodeLens_" .. bufnr, { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
      buffer = bufnr,
      group = group,
      callback = function()
        vim.schedule(function()
          pcall(vim.lsp.codelens.refresh)
        end)
      end,
    })
    -- Trigger codelens refresh on attach
    vim.schedule(function()
      pcall(vim.lsp.codelens.refresh)
    end)
  end
end

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
