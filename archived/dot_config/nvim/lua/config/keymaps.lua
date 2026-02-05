-- Keymaps Configuration
local keymap = vim.keymap.set

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
