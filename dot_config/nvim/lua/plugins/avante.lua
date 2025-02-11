return {
  "yetone/avante.nvim",
  enabled = true,
  event = "VeryLazy",
  lazy = false,
  version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
 
  -- https://github.com/yetone/avante.nvim/blob/main/lua/avante/config.lua
  opts = {
    provider = "claude",
    -- provider = "copilot",
    -- provider = "openai",

    -- Now using copilot.lua and for suggestion
    -- auto_suggestions_provider = "copilot",
    
    behaviour = {
      auto_focus_sidebar = true, -- Whether to automatically focus the sidebar when opening avante.nvim
      auto_suggestions = false, -- Whether to enable auto suggestions.
      auto_apply_diff_after_generation = false, -- Whether to automatically apply diff after LLM response.
      auto_set_keymaps = true, -- Whether to automatically set the keymap for the current line.
      auto_set_highlight_group = true, -- Whether to automatically set the highlight group for the current line.
      jump_result_buffer_on_finish = true, -- Whether to automatically jump to the result buffer after generation
      support_paste_from_clipboard = true, -- Whether to support pasting image from clipboard.
      minimize_diff = false, -- Whether to remove unchanged lines when applying a code block
      enable_token_counting = true, -- Whether to enable token counting.
    },
    
    windows = {
      input = {
        height = 4,
      },
      ask = {
        floating = true, -- Open the 'AvanteAsk' prompt in a floating window
      },
    },
    file_selector = {
      provider = "telescope",
    },
    suggestion = {
      debounce = 75,
      throttle = 100,
    },

    -- provider configs
    copilot = {
      model = "gpt-4o-2024-08-06",
      max_tokens = 4096,
    },
    claude = {
      model = "claude-3-5-sonnet-20240620",
      max_tokens = 8000,
    },
    -- openai = {
    --   endpoint = "https://api.openai.com/v1",
    --   model = "gpt-4o", -- your desired model (or use gpt-4o, etc.)
    --   timeout = 30000, -- timeout in milliseconds
    --   temperature = 0, -- adjust if needed
    --   max_tokens = 4096,
    -- },
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    -- Required dependencies
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    -- Optional dependencies
    "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
