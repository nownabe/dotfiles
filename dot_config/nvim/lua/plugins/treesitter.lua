-- Treesitter Configuration
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "windwp/nvim-ts-autotag",
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        -- Install parsers for all supported languages
        ensure_installed = {
          -- Core
          "vim",
          "vimdoc",
          "query",
          "regex",
          -- Programming languages
          "typescript",
          "tsx",
          "javascript",
          "ruby",
          -- Web
          "html",
          "css",
          "astro",
          -- Data formats
          "json",
          "jsonc",
          "json5",
          "yaml",
          "toml",
          "xml",
          -- Markup
          "markdown",
          "markdown_inline",
          -- Shell/Config
          "bash",
          "dockerfile",
          "proto",
          "terraform",
          "hcl",
          -- Other
          "gitignore",
          "git_config",
          "git_rebase",
          "gitcommit",
          "gitattributes",
        },

        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,

        -- Automatically install missing parsers when entering buffer
        auto_install = true,

        -- Highlight configuration
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },

        -- Indent configuration
        indent = {
          enable = true,
          disable = { "python" }, -- Python indenting is better handled by vim
        },

        -- Auto tag configuration
        autotag = {
          enable = true,
          enable_rename = true,
          enable_close = true,
          enable_close_on_slash = true,
        },

        -- Textobjects configuration
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer",
            },
            goto_next_end = {
              ["]F"] = "@function.outer",
              ["]C"] = "@class.outer",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
            },
            goto_previous_end = {
              ["[F"] = "@function.outer",
              ["[C"] = "@class.outer",
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ["<leader>a"] = "@parameter.inner",
            },
            swap_previous = {
              ["<leader>A"] = "@parameter.inner",
            },
          },
        },

        -- Incremental selection
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
      })
    end,
  },

  -- Treesitter textobjects
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    lazy = true,
  },

  -- Auto tag for HTML/JSX
  {
    "windwp/nvim-ts-autotag",
    lazy = true,
  },

  -- Context commentstring for embedded languages
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    opts = {
      enable_autocmd = false,
    },
    config = function(_, opts)
      vim.g.skip_ts_context_commentstring_module = true
      require("ts_context_commentstring").setup(opts)
    end,
  },
}
