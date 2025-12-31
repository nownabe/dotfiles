-- Editor Enhancement Plugins
return {
  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local autopairs = require("nvim-autopairs")
      autopairs.setup({
        check_ts = true,
        ts_config = {
          lua = { "string" },
          javascript = { "template_string" },
        },
        disable_filetype = { "TelescopePrompt", "spectre_panel" },
        fast_wrap = {
          map = "<M-e>",
          chars = { "{", "[", "(", '"', "'" },
          pattern = [=[[%'%"%>%]%)%}%,]]=],
          end_key = "$",
          keys = "qwertyuiopzxcvbnmasdfghjkl",
          check_comma = true,
          highlight = "Search",
          highlight_grey = "Comment",
        },
      })

      -- Integrate with cmp
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- Comments
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "n", "v" }, desc = "Comment toggle linewise" },
      { "gb", mode = { "n", "v" }, desc = "Comment toggle blockwise" },
    },
    opts = function()
      return {
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      }
    end,
  },

  -- Better buffer closing
  {
    "echasnovski/mini.bufremove",
    keys = {
      {
        "<leader>bd",
        function()
          require("mini.bufremove").delete(0, false)
        end,
        desc = "Delete buffer",
      },
      {
        "<leader>bD",
        function()
          require("mini.bufremove").delete(0, true)
        end,
        desc = "Delete buffer (force)",
      },
      {
        "<leader>bc",
        function()
          require("mini.bufremove").delete(0, false)
        end,
        desc = "Close buffer",
      },
    },
    config = function()
      require("mini.bufremove").setup()
    end,
  },

  -- Terminal
  {
    "akinsho/toggleterm.nvim",
    keys = {
      { "<C-\\>", desc = "Toggle terminal" },
      { "<leader>tf", desc = "Toggle floating terminal" },
      { "<leader>th", desc = "Toggle horizontal terminal" },
      { "<leader>tv", desc = "Toggle vertical terminal" },
    },
    cmd = { "ToggleTerm", "TermExec" },
    opts = {
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = [[<C-\>]],
      hide_numbers = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
        winblend = 0,
      },
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)

      -- Custom terminals
      local Terminal = require("toggleterm.terminal").Terminal

      -- Floating terminal
      local float_term = Terminal:new({
        direction = "float",
        hidden = true,
      })

      function _FLOAT_TERM_TOGGLE()
        float_term:toggle()
      end

      -- Horizontal terminal
      local horizontal_term = Terminal:new({
        direction = "horizontal",
        hidden = true,
      })

      function _HORIZONTAL_TERM_TOGGLE()
        horizontal_term:toggle()
      end

      -- Vertical terminal
      local vertical_term = Terminal:new({
        direction = "vertical",
        hidden = true,
      })

      function _VERTICAL_TERM_TOGGLE()
        vertical_term:toggle()
      end

      -- Keymaps
      vim.keymap.set("n", "<leader>tf", _FLOAT_TERM_TOGGLE, { desc = "Toggle floating terminal" })
      vim.keymap.set("n", "<leader>th", _HORIZONTAL_TERM_TOGGLE, { desc = "Toggle horizontal terminal" })
      vim.keymap.set("n", "<leader>tv", _VERTICAL_TERM_TOGGLE, { desc = "Toggle vertical terminal" })
    end,
  },

  -- Session management
  {
    "stevearc/resession.nvim",
    lazy = true,
    opts = {},
  },

  -- Surround
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- Better text case conversion
  {
    "johmsalas/text-case.nvim",
    keys = {
      { "ga", mode = { "n", "v" }, desc = "Text case" },
    },
    config = function()
      require("textcase").setup({})
    end,
  },

  -- Guess indent
  {
    "NMAC427/guess-indent.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- Smart splits (window management)
  {
    "mrjones2014/smart-splits.nvim",
    lazy = true,
    opts = {},
  },

  -- Trouble - better diagnostics list
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    keys = {
      { "<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace diagnostics (Trouble)" },
      { "<leader>xL", "<cmd>TroubleToggle loclist<cr>", desc = "Location list (Trouble)" },
      { "<leader>xQ", "<cmd>TroubleToggle quickfix<cr>", desc = "Quickfix list (Trouble)" },
      { "[q", function() require("trouble").previous({skip_groups = true, jump = true}) end, desc = "Previous trouble item" },
      { "]q", function() require("trouble").next({skip_groups = true, jump = true}) end, desc = "Next trouble item" },
    },
    opts = {
      use_diagnostic_signs = true,
    },
  },

  -- Better quickfix
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
  },

  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown preview" },
    },
  },

  -- Better escape
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    opts = {
      mapping = { "jk", "jj" },
      timeout = 200,
    },
  },

  -- Highlight undo
  {
    "tzachar/highlight-undo.nvim",
    keys = { "u", "<C-r>" },
    opts = {},
  },
}
