return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup {
        suggestion = {
          enabled = false,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = "<Tab>",
            prev = "<M-[>",
            next = "<M-]>",
            dismiss = "<C-]>",
          },
        },
        panel = { enabled = false },
        copilot_node_command = "node",
        server_opts_overrides = {},
      }
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function() require("copilot_cmp").setup() end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    build = "make tiktoken",
    opts = {
      model = "claude-3.7-sonnet",
      prompts = {
        Explain = {
          prompt = "> /COPILOT_EXPLAIN\n\nWrite an explanation in Japanese for the selected code as paragraphs of text.",
          mapping = "<leader>ce",
          description = "Explain the selected code",
        },
        Review = {
          prompt = "> /COPILOT_REVIEW\n\nReview the selected code in Japanese.",
          mapping = "<leader>cr",
          description = "Review the selected code",
        },
        Fix = {
          prompt = "> /COPILOT_GENERATE\n\nThere is a problem in this code. Rewrite the code to show it with the bug fixed.",
          mapping = "<leader>cf",
          description = "Fix the code",
        },
        Optimize = {
          prompt = "> /COPILOT_GENERATE\n\nOptimize the selected code to improve performance and readability.",
          mapping = "<leader>co",
          description = "Optimize the selected code",
        },
        Docs = {
          prompt = "> /COPILOT_GENERATE\n\nPlease add documentation comments to the selected code.",
          mapping = "<leader>cd",
          description = "Add documentation to the selected code",
        },
        Tests = {
          prompt = "> /COPILOT_GENERATE\n\nPlease generate tests for my code.",
          mapping = "<leader>ct",
          description = "Add tests for the code",
        },
        Commit = {
          prompt = "> #git:staged\n\nWrite commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.",
        },
      },
    },
  },
}
