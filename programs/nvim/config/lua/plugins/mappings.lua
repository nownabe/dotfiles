return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {
          -- Disable default mappings (astrocore / snacks.nvim)
          ["<Leader>t"] = { "<Cmd>ToggleTerm direction=float<CR>", desc = " Toggle terminal" },
          ["<Leader>tf"] = false,
          ["<Leader>th"] = false,
          ["<Leader>tl"] = false,
          ["<Leader>tn"] = false,
          ["<Leader>tp"] = false,
          ["<Leader>tt"] = false,
          ["<Leader>tu"] = false,
          ["<Leader>tv"] = false,
          ["<Leader>n"] = false,
          ["<Leader>s"] = { desc = "󰚩 Sidekick" },
          ["<Leader>f'"] = false,
          ["<Leader>fm"] = false,
          ["<Leader>fw"] = false,
          ["<Leader>fW"] = false,
          ["<Leader>ld"] = false,
          ["<Leader>lD"] = false,
          ["<Leader>lk"] = false,
          ["<Leader>ls"] = false,
          ["<Leader>lS"] = false,

          -- Disable default buffer mappings
          ["<Leader>bC"] = false,
          ["<Leader>bp"] = false,
          ["<Leader>br"] = false,
          ["<Leader>bs"] = false,
          ["<Leader>bse"] = false,
          ["<Leader>bsi"] = false,
          ["<Leader>bsm"] = false,
          ["<Leader>bsp"] = false,
          ["<Leader>bsr"] = false,
          ["<Leader>c"] = false,
          ["<Leader>C"] = false,

          -- Disable default g* LSP mappings
          ["gD"] = false,
          ["gd"] = false,
          ["gI"] = false,
          ["gra"] = false,
          ["gri"] = false,
          ["grn"] = false,
          ["grr"] = false,
          ["grt"] = false,
          ["gl"] = false,
          ["gy"] = false,
          ["K"] = false,

          -- Buffer management (overrides default <Leader>bc and <Leader>bl)
          ["<Leader>bh"] = {
            function() require("astrocore.buffer").nav(-vim.v.count1) end,
            desc = "󰜲 Previous buffer",
          },
          ["<Leader>bl"] = {
            function() require("astrocore.buffer").nav(vim.v.count1) end,
            desc = "󰜵 Next buffer",
          },
          ["<Leader>bc"] = {
            function() require("astrocore.buffer").close() end,
            desc = "󰅖 Close current buffer",
          },

          -- Cursor navigation (overrides default <Leader>h and <Leader>l)
          ["<Leader>h"] = { "^", desc = "󰜲 Move to first non-whitespace" },
          ["<Leader>l"] = { "$", desc = "󰜵 Move to end of line" },
          ["<Leader>m"] = { "<Plug>(matchup-%)", desc = "󰅪 Match nearest [], (), {}" },

          -- Find files (git files in git repo, otherwise normal find)
          ["<Leader>ff"] = {
            function()
              vim.fn.system("git rev-parse --is-inside-work-tree")
              if vim.v.shell_error == 0 then
                Snacks.picker.git_files()
              else
                Snacks.picker.files()
              end
            end,
            desc = "Find files",
          },

          -- Grep
          ["<Leader>fg"] = {
            function() Snacks.picker.grep() end,
            desc = "Grep",
          },
          ["<Leader>fG"] = {
            function() Snacks.picker.grep({ hidden = true, ignored = true }) end,
            desc = "Grep (all files)",
          },

          -- Diagnostics
          ["<Leader>;n"] = {
            function() vim.diagnostic.open_float() end,
            desc = "Hover diagnostics",
          },
          ["<Leader>;N"] = {
            function() Snacks.picker.diagnostics() end,
            desc = "Search diagnostics",
          },
        },
        v = {
          ["<Leader>la"] = false,

          -- Copy GitHub URL for selected lines
          ["<Leader>y"] = {
            function()
              local line_start = vim.fn.line("v")
              local line_end = vim.fn.line(".")
              if line_start > line_end then
                line_start, line_end = line_end, line_start
              end
              local copy = function(url)
                vim.fn.setreg("+", url)
                vim.notify("Copied: " .. url)
              end
              vim.ui.select({ "Permalink (commit)", "Default branch" }, { prompt = "Copy GitHub URL" }, function(choice)
                if not choice then return end
                if choice == "Permalink (commit)" then
                  Snacks.gitbrowse.open({
                    what = "permalink",
                    line_start = line_start,
                    line_end = line_end,
                    notify = false,
                    open = copy,
                  })
                else
                  local branch = vim.trim(vim.fn.system("git rev-parse --abbrev-ref origin/HEAD")):gsub("^origin/", "")
                  Snacks.gitbrowse.open({
                    what = "file",
                    branch = branch,
                    line_start = line_start,
                    line_end = line_end,
                    notify = false,
                    open = copy,
                  })
                end
              end)
            end,
            desc = "Copy GitHub URL",
          },
        },
      },
    },
  },
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      mappings = {
        n = {
          -- Disable default Language Tools group (astrolsp)
          ["<Leader>l"] = false,
          ["<Leader>la"] = false,
          ["<Leader>lA"] = false,
          ["<Leader>lf"] = false,
          ["<Leader>lG"] = false,
          ["<Leader>lh"] = false,
          ["<Leader>ll"] = false,
          ["<Leader>lL"] = false,
          ["<Leader>lr"] = false,
          ["<Leader>lR"] = false,
          ["<Leader>li"] = false,
          ["<Leader>lI"] = false,

          -- Language Tools group
          ["<Leader>;"] = { desc = " Language Tools" },

          -- LSP actions
          ["<Leader>;a"] = {
            function() vim.lsp.buf.code_action() end,
            desc = "Code action",
            cond = "textDocument/codeAction",
          },
          ["<Leader>;A"] = {
            function() vim.lsp.buf.code_action({ context = { only = { "source" }, diagnostics = {} } }) end,
            desc = "Source action",
            cond = "textDocument/codeAction",
          },

          -- Navigation
          ["<Leader>;d"] = {
            function() vim.lsp.buf.definition() end,
            desc = "Definition",
            cond = "textDocument/definition",
          },
          ["<Leader>;D"] = {
            function() vim.lsp.buf.declaration() end,
            desc = "Declaration",
            cond = "textDocument/declaration",
          },
          ["<Leader>;t"] = {
            function() vim.lsp.buf.type_definition() end,
            desc = "Type definition",
            cond = "textDocument/typeDefinition",
          },
          ["<Leader>;i"] = {
            function() Snacks.picker.lsp_implementations() end,
            desc = "Implementations",
          },
          ["<Leader>;r"] = {
            function() Snacks.picker.lsp_references() end,
            desc = "References",
          },

          -- Info
          ["<Leader>;h"] = {
            function() vim.lsp.buf.hover() end,
            desc = "Hover",
            cond = "textDocument/hover",
          },
          ["<Leader>;s"] = {
            function() require("aerial").toggle() end,
            desc = "Symbols outline",
          },
          ["<Leader>;H"] = {
            function() vim.lsp.buf.signature_help() end,
            desc = "Signature help",
            cond = "textDocument/signatureHelp",
          },

          -- Refactoring
          ["<Leader>;R"] = {
            function() vim.lsp.buf.rename() end,
            desc = "Rename symbol",
            cond = "textDocument/rename",
          },
          ["<Leader>;f"] = {
            function() vim.lsp.buf.format(require("astrolsp").format_opts) end,
            desc = "Format buffer",
            cond = "textDocument/formatting",
          },

          -- CodeLens
          ["<Leader>;L"] = {
            function() vim.lsp.codelens.refresh() end,
            desc = "CodeLens refresh",
            cond = "textDocument/codeLens",
          },
          ["<Leader>;l"] = {
            function() vim.lsp.codelens.run() end,
            desc = "CodeLens run",
            cond = "textDocument/codeLens",
          },

          -- Search
          ["<Leader>;S"] = {
            function() Snacks.picker.lsp_workspace_symbols() end,
            desc = "Workspace symbols",
          },
          ["<Leader>;o"] = {
            function() Snacks.picker.lsp_symbols() end,
            desc = "Document symbols",
          },
        },
        v = {
          ["<Leader>l"] = false,
          ["<Leader>lf"] = false,

          ["<Leader>;"] = { desc = " Language Tools" },
          ["<Leader>;a"] = {
            function() vim.lsp.buf.code_action() end,
            desc = "Code action",
            cond = "textDocument/codeAction",
          },
          ["<Leader>;f"] = {
            function() vim.lsp.buf.format(require("astrolsp").format_opts) end,
            desc = "Format buffer",
            cond = "textDocument/rangeFormatting",
          },
        },
        x = {
          ["<Leader>la"] = false,

          ["<Leader>;a"] = {
            function() vim.lsp.buf.code_action() end,
            desc = "Code action",
            cond = "textDocument/codeAction",
          },
        },
      },
    },
  },
}
