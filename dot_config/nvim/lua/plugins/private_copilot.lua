-- Copilot Configuration
return {
  -- Copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = {
          enabled = false,
          auto_refresh = false,
        },
        suggestion = {
          enabled = false, -- Using cmp instead
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = "<M-l>",
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        filetypes = {
          yaml = true,
          markdown = true,
          help = false,
          gitcommit = true,
          gitrebase = true,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["."] = false,
        },
        copilot_node_command = "node",
        server_opts_overrides = {},
      })
    end,
  },

  -- Copilot CMP source
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua" },
    config = function()
      require("copilot_cmp").setup()
    end,
  },

  -- CopilotChat
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    cmd = {
      "CopilotChat",
      "CopilotChatOpen",
      "CopilotChatClose",
      "CopilotChatToggle",
      "CopilotChatReset",
      "CopilotChatExplain",
      "CopilotChatReview",
      "CopilotChatFix",
      "CopilotChatOptimize",
      "CopilotChatDocs",
      "CopilotChatTests",
      "CopilotChatCommit",
    },
    keys = {
      { "<leader>cce", "<cmd>CopilotChatExplain<cr>", mode = "v", desc = "Explain code" },
      { "<leader>ccr", "<cmd>CopilotChatReview<cr>", mode = "v", desc = "Review code" },
      { "<leader>ccf", "<cmd>CopilotChatFix<cr>", mode = "v", desc = "Fix code" },
      { "<leader>cco", "<cmd>CopilotChatOptimize<cr>", mode = "v", desc = "Optimize code" },
      { "<leader>ccd", "<cmd>CopilotChatDocs<cr>", mode = "v", desc = "Add documentation" },
      { "<leader>cct", "<cmd>CopilotChatTests<cr>", mode = "v", desc = "Generate tests" },
      { "<leader>ccm", "<cmd>CopilotChatCommit<cr>", desc = "Generate commit message" },
      { "<leader>ccc", "<cmd>CopilotChatToggle<cr>", desc = "Toggle Copilot Chat" },
      { "<leader>ccq", function()
        local input = vim.fn.input("Quick Chat: ")
        if input ~= "" then
          require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
        end
      end, desc = "Quick chat" },
    },
    opts = {
      debug = false,
      model = "claude-3.5-sonnet",
      temperature = 0.1,
      question_header = "## User ",
      answer_header = "## Copilot ",
      error_header = "## Error ",
      separator = "───",
      show_folds = true,
      show_help = true,
      auto_follow_cursor = true,
      auto_insert_mode = false,
      clear_chat_on_new_prompt = false,
      context = nil,
      history_path = vim.fn.stdpath("data") .. "/copilotchat_history",
      callback = nil,

      -- Custom prompts in Japanese
      prompts = {
        Explain = {
          prompt = "> /COPILOT_EXPLAIN\n\n選択されたコードについて、段落形式で日本語で説明を書いてください。",
        },
        Review = {
          prompt = "> /COPILOT_REVIEW\n\n選択されたコードを日本語でレビューしてください。",
        },
        Fix = {
          prompt = "> /COPILOT_GENERATE\n\nこのコードに問題があります。バグを修正したコードに書き直してください。",
        },
        Optimize = {
          prompt = "> /COPILOT_GENERATE\n\n選択されたコードを最適化して、パフォーマンスと可読性を向上させてください。",
        },
        Docs = {
          prompt = "> /COPILOT_GENERATE\n\n選択されたコードにドキュメントコメントを追加してください。",
        },
        Tests = {
          prompt = "> /COPILOT_GENERATE\n\n選択されたコードのテストを生成してください。",
        },
        Commit = {
          prompt = "> #git:staged\n\nCommitizen の規約に従ってコミットメッセージを書いてください。タイトルは最大50文字、メッセージは72文字で折り返してください。メッセージ全体を gitcommit 言語のコードブロックで囲んでください。",
        },
      },

      -- Window configuration
      window = {
        layout = "vertical",
        width = 0.4,
        height = 0.6,
        relative = "editor",
        border = "rounded",
        title = "Copilot Chat",
      },

      -- Mappings
      mappings = {
        complete = {
          detail = "Use @<Tab> or /<Tab> for options.",
          insert = "<Tab>",
        },
        close = {
          normal = "q",
          insert = "<C-c>",
        },
        reset = {
          normal = "<C-r>",
          insert = "<C-r>",
        },
        submit_prompt = {
          normal = "<CR>",
          insert = "<C-s>",
        },
        accept_diff = {
          normal = "<C-y>",
          insert = "<C-y>",
        },
        yank_diff = {
          normal = "gy",
        },
        show_diff = {
          normal = "gd",
        },
        show_system_prompt = {
          normal = "gp",
        },
        show_user_selection = {
          normal = "gs",
        },
      },
    },
    config = function(_, opts)
      local chat = require("CopilotChat")
      local select = require("CopilotChat.select")

      -- Use unnamed register for the selection
      opts.selection = select.unnamed

      chat.setup(opts)

      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-*",
        callback = function()
          vim.opt_local.relativenumber = true
          vim.opt_local.number = true

          -- Get current filetype and set it to markdown if the current filetype is copilot-chat
          local ft = vim.bo.filetype
          if ft == "copilot-chat" then
            vim.bo.filetype = "markdown"
          end
        end,
      })
    end,
  },
}
