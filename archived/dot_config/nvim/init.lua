-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- ref. https://lazy.folke.io/installation
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.lazy")
