-- Snacks.nvim Configuration
-- Quality of life plugins collection including picker (fuzzy finder)
return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    -- Dashboard configuration
    dashboard = {
      preset = {
        keys = {
          { key = "n", action = ":enew", icon = " ", desc = "New File" },
          { key = "f", action = "<Leader>ff", icon = " ", desc = "Find File" },
          { key = "o", action = "<Leader>fo", icon = " ", desc = "Recent Files" },
          { key = "w", action = "<Leader>fw", icon = " ", desc = "Find Word" },
          { key = "q", action = ":qa", icon = " ", desc = "Quit" },
        },
        header = table.concat({
          "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
          "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
          "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
          "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
          "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
          "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
        }, "\n"),
      },
      sections = {
        { section = "header", padding = 5 },
        { section = "keys", gap = 1, padding = 3 },
        { section = "startup" },
      },
    },

    -- Image support
    image = { doc = { enabled = false } },

    -- Input configuration
    input = {},

    -- Notification system
    notifier = {
      icons = {
        debug = " ",
        error = " ",
        info = " ",
        trace = " ",
        warn = " ",
      },
    },

    -- Picker configuration (fuzzy finder)
    picker = {
      ui_select = true, -- Use snacks picker for vim.ui.select
    },

    -- Indent guides
    indent = {
      indent = { char = "▏" },
      scope = { char = "▏" },
      animate = { enabled = false },
    },

    -- Scope highlighting
    scope = {},

    -- Zen mode
    zen = {
      toggles = { dim = false, diagnostics = false, inlay_hints = false },
      win = {
        width = function()
          return math.min(120, math.floor(vim.o.columns * 0.75))
        end,
        height = 0.9,
        backdrop = {
          transparent = false,
        },
        wo = {
          number = false,
          relativenumber = false,
          signcolumn = "no",
          foldcolumn = "0",
          winbar = "",
          list = false,
          showbreak = "NONE",
        },
      },
    },
  },

  keys = {
    -- Dashboard
    {
      "<leader>h",
      function()
        if vim.bo.filetype == "snacks_dashboard" then
          vim.cmd("bd")
        else
          require("snacks").dashboard()
        end
      end,
      desc = "Toggle Dashboard",
    },

    -- Indent guides
    {
      "<leader>u|",
      function()
        require("snacks").toggle.indent():toggle()
      end,
      desc = "Toggle indent guides",
    },

    -- Notifications
    {
      "<leader>uD",
      function()
        require("snacks.notifier").hide()
      end,
      desc = "Dismiss notifications",
    },

    -- Zen mode
    {
      "<leader>uZ",
      function()
        require("snacks").toggle.zen():toggle()
      end,
      desc = "Toggle zen mode",
    },

    -- Git browse
    {
      "<leader>go",
      function()
        require("snacks").gitbrowse()
      end,
      desc = "Git browse (open)",
      mode = { "n", "x" },
    },

    -- File pickers
    {
      "<leader>ff",
      function()
        require("snacks").picker.files({
          hidden = vim.fn.isdirectory(".git") == 1,
        })
      end,
      desc = "Find files",
    },
    {
      "<leader>fF",
      function()
        require("snacks").picker.files({ hidden = true, ignored = true })
      end,
      desc = "Find all files",
    },
    {
      "<leader>fg",
      function()
        require("snacks").picker.git_files()
      end,
      desc = "Find git files",
    },
    {
      "<leader>fo",
      function()
        require("snacks").picker.recent()
      end,
      desc = "Recent files",
    },
    {
      "<leader>fO",
      function()
        require("snacks").picker.recent({ filter = { cwd = true } })
      end,
      desc = "Recent files (cwd)",
    },
    {
      "<leader>fb",
      function()
        require("snacks").picker.buffers()
      end,
      desc = "Find buffers",
    },

    -- Search pickers
    {
      "<leader>fw",
      function()
        require("snacks").picker.grep()
      end,
      desc = "Find words (grep)",
    },
    {
      "<leader>fW",
      function()
        require("snacks").picker.grep({ hidden = true, ignored = true })
      end,
      desc = "Find words in all files",
    },
    {
      "<leader>fc",
      function()
        require("snacks").picker.grep_word()
      end,
      desc = "Find word under cursor",
    },
    {
      "<leader>fl",
      function()
        require("snacks").picker.lines()
      end,
      desc = "Find lines",
    },

    -- LSP pickers
    {
      "<leader>fs",
      function()
        require("snacks").picker.lsp_symbols()
      end,
      desc = "Document symbols",
    },
    {
      "<leader>fS",
      function()
        require("snacks").picker.lsp_symbols()
      end,
      desc = "Workspace symbols",
    },
    {
      "<leader>lD",
      function()
        require("snacks").picker.diagnostics()
      end,
      desc = "Search diagnostics",
    },
    {
      "<leader>ls",
      function()
        require("snacks").picker.lsp_symbols()
      end,
      desc = "Search symbols",
    },

    -- Misc pickers
    {
      "<leader>fh",
      function()
        require("snacks").picker.help()
      end,
      desc = "Find help",
    },
    {
      "<leader>fC",
      function()
        require("snacks").picker.commands()
      end,
      desc = "Find commands",
    },
    {
      "<leader>fk",
      function()
        require("snacks").picker.keymaps()
      end,
      desc = "Find keymaps",
    },
    {
      "<leader>ft",
      function()
        require("snacks").picker.colorschemes()
      end,
      desc = "Find colorschemes",
    },
    {
      "<leader>f'",
      function()
        require("snacks").picker.marks()
      end,
      desc = "Find marks",
    },
    {
      "<leader>fr",
      function()
        require("snacks").picker.registers()
      end,
      desc = "Find registers",
    },
    {
      "<leader>fu",
      function()
        require("snacks").picker.undo()
      end,
      desc = "Find undo history",
    },
    {
      "<leader>f<CR>",
      function()
        require("snacks").picker.resume()
      end,
      desc = "Resume previous search",
    },

    -- Git pickers
    {
      "<leader>gc",
      function()
        require("snacks").picker.git_log()
      end,
      desc = "Git commits (repository)",
    },
    {
      "<leader>gC",
      function()
        require("snacks").picker.git_log({ current_file = true, follow = true })
      end,
      desc = "Git commits (current file)",
    },
    {
      "<leader>gb",
      function()
        require("snacks").picker.git_branches()
      end,
      desc = "Git branches",
    },
    {
      "<leader>gt",
      function()
        require("snacks").picker.git_status()
      end,
      desc = "Git status",
    },
    {
      "<leader>gT",
      function()
        require("snacks").picker.git_stash()
      end,
      desc = "Git stash",
    },
  },
}
