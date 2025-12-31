-- Telescope Configuration
return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    keys = {
      -- File pickers
      {
        "<leader>ff",
        function()
          require("telescope.builtin").find_files({ hidden = true })
        end,
        desc = "Find files (including hidden)",
      },
      {
        "<leader>fF",
        function()
          require("telescope.builtin").find_files({ hidden = false })
        end,
        desc = "Find files",
      },
      {
        "<leader>fr",
        function()
          require("telescope.builtin").oldfiles()
        end,
        desc = "Recent files",
      },
      {
        "<leader>fb",
        function()
          require("telescope.builtin").buffers()
        end,
        desc = "Find buffers",
      },

      -- Search pickers
      {
        "<leader>fg",
        function()
          require("telescope.builtin").live_grep({ additional_args = { "--hidden" } })
        end,
        desc = "Live grep (including hidden)",
      },
      {
        "<leader>fG",
        function()
          require("telescope.builtin").git_files()
        end,
        desc = "Find git files",
      },
      {
        "<leader>fw",
        function()
          require("telescope.builtin").grep_string()
        end,
        desc = "Grep word under cursor",
      },

      -- LSP pickers
      {
        "<leader>fs",
        function()
          require("telescope.builtin").lsp_document_symbols()
        end,
        desc = "Document symbols",
      },
      {
        "<leader>fS",
        function()
          require("telescope.builtin").lsp_workspace_symbols()
        end,
        desc = "Workspace symbols",
      },

      -- Misc pickers
      {
        "<leader>fh",
        function()
          require("telescope.builtin").help_tags()
        end,
        desc = "Help tags",
      },
      {
        "<leader>fc",
        function()
          require("telescope.builtin").commands()
        end,
        desc = "Commands",
      },
      {
        "<leader>fk",
        function()
          require("telescope.builtin").keymaps()
        end,
        desc = "Keymaps",
      },
      {
        "<leader>fo",
        function()
          require("telescope.builtin").vim_options()
        end,
        desc = "Vim options",
      },
      {
        "<leader>fC",
        function()
          require("telescope.builtin").colorscheme({ enable_preview = true })
        end,
        desc = "Colorscheme",
      },

      -- Git pickers
      {
        "<leader>gc",
        function()
          require("telescope.builtin").git_commits()
        end,
        desc = "Git commits",
      },
      {
        "<leader>gs",
        function()
          require("telescope.builtin").git_status()
        end,
        desc = "Git status",
      },
      {
        "<leader>gb",
        function()
          require("telescope.builtin").git_branches()
        end,
        desc = "Git branches",
      },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          path_display = { "smart" },
          file_ignore_patterns = { ".git/", "node_modules" },
          mappings = {
            i = {
              ["<C-n>"] = actions.cycle_history_next,
              ["<C-p>"] = actions.cycle_history_prev,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-c>"] = actions.close,
              ["<Down>"] = actions.move_selection_next,
              ["<Up>"] = actions.move_selection_previous,
              ["<CR>"] = actions.select_default,
              ["<C-h>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,
              ["<PageUp>"] = actions.results_scrolling_up,
              ["<PageDown>"] = actions.results_scrolling_down,
              ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
              ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<C-l>"] = actions.complete_tag,
              ["<C-_>"] = actions.which_key, -- <C-/>
            },
            n = {
              ["<esc>"] = actions.close,
              ["<CR>"] = actions.select_default,
              ["<C-h>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
              ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
              ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["j"] = actions.move_selection_next,
              ["k"] = actions.move_selection_previous,
              ["H"] = actions.move_to_top,
              ["M"] = actions.move_to_middle,
              ["L"] = actions.move_to_bottom,
              ["<Down>"] = actions.move_selection_next,
              ["<Up>"] = actions.move_selection_previous,
              ["gg"] = actions.move_to_top,
              ["G"] = actions.move_to_bottom,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,
              ["<PageUp>"] = actions.results_scrolling_up,
              ["<PageDown>"] = actions.results_scrolling_down,
              ["?"] = actions.which_key,
            },
          },
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--glob=!.git/",
          },
        },
        pickers = {
          find_files = {
            find_command = { "rg", "--files", "--hidden", "--glob=!.git/" },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
      })

      -- Load extensions
      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
    end,
  },

  -- FZF sorter for telescope
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    lazy = true,
  },

  -- UI select extension
  {
    "nvim-telescope/telescope-ui-select.nvim",
    lazy = true,
  },
}
