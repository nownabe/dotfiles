-- Neovim Options Configuration
local opt = vim.opt

-- General
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.wrap = true

-- Tabs and indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Appearance
opt.termguicolors = true
opt.background = "dark"
opt.pumheight = 10

-- Clipboard
opt.clipboard = "unnamedplus"

-- Split windows
opt.splitright = true
opt.splitbelow = true

-- Backup
opt.backup = false
opt.swapfile = false
opt.writebackup = true

-- Folding (for nvim-ufo)
opt.foldcolumn = "1"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

-- Scrolling
opt.scrolloff = 16
opt.sidescrolloff = 8

-- Performance
opt.updatetime = 300
opt.timeoutlen = 300

-- Mouse
opt.mouse = "a"

-- Command line
opt.cmdheight = 1
opt.showmode = false

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }

-- Hidden characters
opt.list = false
opt.listchars = { tab = "→ ", trail = "·", nbsp = "␣" }

-- Session options
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
