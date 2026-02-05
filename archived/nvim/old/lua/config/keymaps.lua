-- Keymaps Configuration
local M = {}
local keymap = vim.keymap.set

function M.setup()
  -- Better window navigation
  keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left window", silent = true })
  keymap("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", silent = true })
  keymap("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", silent = true })
  keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right window", silent = true })

  -- Resize with arrows
  keymap("n", "<C-Up>", ":resize -2<CR>", { desc = "Decrease window height", silent = true })
  keymap("n", "<C-Down>", ":resize +2<CR>", { desc = "Increase window width", silent = true })
  keymap("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width", silent = true })
  keymap("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width", silent = true })

  -- Navigate buffers
  keymap("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer", silent = true })
  keymap("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer", silent = true })

  -- Stay in indent mode
  keymap("v", "<", "<gv", { desc = "Decrease indent" })
  keymap("v", ">", ">gv", { desc = "Increase indent" })

  -- Better paste
  keymap("v", "p", '"_dP', { desc = "Paste without yanking" })

  -- Clear search highlights
  keymap("n", "<Esc>", ":noh<CR>", { desc = "Clear highlights", silent = true })

  -- Better line movement
  keymap("n", "j", "gj", { desc = "Move down", silent = true })
  keymap("n", "k", "gk", { desc = "Move up", silent = true })

  -- Quick save
  keymap("n", "<C-s>", ":w<CR>", { desc = "Save file", silent = true })
  keymap("i", "<C-s>", "<Esc>:w<CR>a", { desc = "Save file", silent = true })

  -- Move lines
  keymap("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
  keymap("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up", silent = true })
  keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })
  keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })
end

function M.lsp(bufnr)
  local opts = { buffer = bufnr, silent = true }

  -- LSP keymaps under <Leader>;
  keymap("n", "<Leader>;d", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
  keymap("n", "<Leader>;D", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
  keymap("n", "<Leader>;i", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
  keymap("n", "<Leader>;t", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Go to type definition" }))
  keymap("n", "<Leader>;R", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Show references" }))
  keymap("n", "<Leader>;r", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
  keymap("n", "<Leader>;h", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
  keymap("n", "<Leader>;s", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature help" }))
  keymap({ "n", "v" }, "<Leader>;a", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
  keymap("n", "<Leader>;f", function()
    vim.lsp.buf.format({ async = true })
  end, vim.tbl_extend("force", opts, { desc = "Format buffer" }))

  -- Diagnostic keymaps
  keymap("n", "<Leader>;n", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Show diagnostic" }))
  keymap("n", "<Leader>;N", vim.diagnostic.setloclist, vim.tbl_extend("force", opts, { desc = "Diagnostics list" }))
  keymap("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
  keymap("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))

  -- Additional useful keymaps
  keymap("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
  keymap("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
  keymap("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "References" }))
  keymap("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
  keymap("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
end

M.setup()

-- NOTE: Keymaps that stay outside this file due to plugin/autocmd/lazy requirements:
-- - lua/config/autocmds.lua (buffer-local "q" close on FileType)
-- - lua/plugins/git.lua (gitsigns buffer-local on_attach maps)
-- - lua/plugins/ui.lua (illuminate/noice/notify lazy-loaded maps)
-- - lua/plugins/snacks.lua (snacks picker lazy-loaded maps)
-- - lua/plugins/neo-tree.lua (neo-tree lazy-loaded maps + window mappings)
-- - lua/plugins/editor.lua (plugin-specific lazy-loaded maps)
-- - lua/plugins/lsp.lua (Aerial lazy-loaded map)
-- - lua/plugins/lang/go.lua (gopher.nvim maps)
-- - lua/plugins/treesitter.lua (textobjects + incremental selection keymaps)
-- - lua/plugins/completion.lua (cmp insert/cmdline mappings)
-- - lua/plugins/copilot.lua (copilot suggestion + CopilotChat mappings)

return M
