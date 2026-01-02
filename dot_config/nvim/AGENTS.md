# Neovim Configuration

Standalone Neovim configuration migrated from AstroNvim v5.3.14 to use lazy.nvim directly.

## Overview

This configuration provides a full-featured IDE experience with LSP, Treesitter, completion, and extensive language support. It maintains feature parity with AstroNvim while removing dependency on the AstroNvim framework.

**Key Technologies:**
- **Plugin Manager**: lazy.nvim
- **LSP**: nvim-lspconfig + mason.nvim + mason-lspconfig.nvim
- **Completion**: nvim-cmp + copilot.lua + copilot-cmp
- **Syntax**: nvim-treesitter
- **UI**: snacks.nvim, noice.nvim, which-key.nvim, alpha-nvim
- **Git**: gitsigns.nvim, lazygit.nvim, diffview.nvim

## Directory Structure

```
~/.config/nvim/
├── init.lua                          # Entry point
├── lua/
│   ├── config/
│   │   ├── lazy.lua                  # lazy.nvim bootstrap
│   │   ├── init.lua                  # Load all config modules
│   │   ├── options.lua               # Vim options (vim.opt)
│   │   ├── keymaps.lua               # Global keymaps
│   │   └── autocmds.lua              # Autocommands
│   ├── plugins/
│   │   ├── colorscheme.lua           # Catppuccin theme
│   │   ├── treesitter.lua            # Syntax highlighting
│   │   ├── lsp.lua                   # LSP configuration
│   │   ├── completion.lua            # Completion setup
│   │   ├── snacks.lua                # Fuzzy finder and QoL plugins
│   │   ├── neo-tree.lua              # File explorer
│   │   ├── ui.lua                    # UI plugins
│   │   ├── editor.lua                # Editor enhancements
│   │   ├── git.lua                   # Git integration
│   │   ├── copilot.lua               # AI assistance
│   │   └── lang/                     # Language-specific configs
│   │       ├── go.lua
│   │       ├── python.lua
│   │       ├── rust.lua
│   │       ├── typescript.lua
│   │       └── ... (18 more)
│   └── utils/
│       └── init.lua                  # Helper functions
└── AGENTS.md                         # This file
```

## Features

### Core Features
- ✅ LSP support for 22+ languages
- ✅ Treesitter syntax highlighting
- ✅ Intelligent code completion with Copilot
- ✅ Fuzzy finding with Snacks Picker
- ✅ File explorer with Neo-tree
- ✅ Git integration with gitsigns and lazygit
- ✅ Project-local LSP settings with neoconf
- ✅ Format on save
- ✅ Inlay hints and codelens
- ✅ Custom keymaps with which-key
- ✅ Dashboard, notifications, indent guides, and zen mode with Snacks

### Language Support

**Languages with full LSP + Treesitter:**
- Go (gopls, gopher.nvim, nvim-dap-go)
- Python (pyright, nvim-dap-python)
- Rust (rust_analyzer, rustaceanvim, crates.nvim)
- TypeScript/JavaScript (ts_ls, nvim-vtsls, tsc.nvim, package-info.nvim)
- Lua (lua_ls, lazydev.nvim)
- HTML/CSS (html, cssls, nvim-ts-autotag)
- JSON (jsonls, schemastore.nvim)
- YAML (yamlls, schemastore.nvim)
- Markdown (marksman)
- Bash (bashls)
- Docker (dockerls)
- Terraform (terraformls)
- TOML (taplo)
- Protocol Buffers
- Ruby (solargraph)
- Tailwind CSS (tailwindcss)
- Astro (astro)
- Chezmoi
- CUE
- MDX
- Rego

## Key Mappings

### Leader Keys
- `<Space>` - Leader key
- `\` - Local leader key

### LSP Keymaps (under `<Leader>;`)
| Key | Action | Description |
|-----|--------|-------------|
| `<Leader>;d` | Go to definition | Jump to symbol definition |
| `<Leader>;D` | Go to declaration | Jump to symbol declaration |
| `<Leader>;i` | Go to implementation | Jump to implementation |
| `<Leader>;t` | Type definition | Show type definition |
| `<Leader>;R` | References | Show all references |
| `<Leader>;r` | Rename | Rename symbol |
| `<Leader>;h` | Hover | Show hover documentation |
| `<Leader>;s` | Signature help | Show signature help |
| `<Leader>;a` | Code action | Show code actions |
| `<Leader>;f` | Format | Format buffer |
| `<Leader>;n` | Show diagnostic | Open diagnostic float |
| `<Leader>;N` | Diagnostics list | Show all diagnostics |

### Standard LSP Shortcuts
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Show references |
| `gi` | Go to implementation |
| `K` | Hover documentation |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |

### Buffer Navigation
| Key | Action |
|-----|--------|
| `<Leader>bh` | Previous buffer |
| `<Leader>bl` | Next buffer |
| `<Leader>bc` | Close buffer |

### Snacks Picker (Find)
| Key | Action |
|-----|--------|
| `<Leader>ff` | Find files |
| `<Leader>fF` | Find all files (hidden/ignored) |
| `<Leader>fg` | Find git files |
| `<Leader>fo` | Recent files |
| `<Leader>fb` | Find buffers |
| `<Leader>fw` | Find words (grep) |
| `<Leader>fc` | Find word under cursor |
| `<Leader>fs` | Document symbols |
| `<Leader>fh` | Find help |
| `<Leader>fk` | Find keymaps |
| `<Leader>fC` | Find commands |
| `<Leader>ft` | Find themes |
| `<Leader>f<CR>` | Resume previous search |

### Git
| Key | Action |
|-----|--------|
| `<Leader>gg` | Open LazyGit |
| `<Leader>gf` | LazyGit current file |
| `<Leader>gd` | Open diffview |
| `<Leader>gh` | File history |
| `]c` | Next git hunk |
| `[c` | Previous git hunk |
| `<Leader>hs` | Stage hunk |
| `<Leader>hr` | Reset hunk |
| `<Leader>hp` | Preview hunk |

### Copilot
| Key | Action |
|-----|--------|
| `<Tab>` | Accept completion (when visible) |
| `<Leader>cc` | Open Copilot Chat |

### Completion
| Key | Action |
|-----|--------|
| `<Tab>` | Confirm completion / Jump snippet |
| `<S-Tab>` | Previous item / Jump back |
| `<C-Space>` | Trigger completion |
| `<C-e>` | Abort completion |
| `<Down>` | Next item |
| `<Up>` | Previous item |

## LSP Configuration

### Installed Servers
- lua_ls (Lua)
- gopls (Go)
- pyright (Python)
- rust_analyzer (Rust)
- ts_ls (TypeScript/JavaScript)
- html (HTML)
- cssls (CSS)
- jsonls (JSON)
- yamlls (YAML)
- marksman (Markdown)
- bashls (Bash)
- dockerls (Docker)
- terraformls (Terraform)
- taplo (TOML)
- solargraph (Ruby)
- astro (Astro)
- tailwindcss (Tailwind CSS)

### Custom Configurations

**lua_ls:**
- Recognizes `vim` global
- Includes Neovim runtime paths
- Inlay hints enabled

**gopls:**
- Static analysis with staticcheck
- gofumpt formatting
- Inlay hints for types and parameters

**ts_ls:**
- Formatting disabled (use prettier)
- Inlay hints for parameters and types

**jsonls/yamlls:**
- JSON/YAML schema validation with schemastore

## Plugins

### Core
- **lazy.nvim** - Plugin manager
- **plenary.nvim** - Utility library

### LSP & Completion
- **nvim-lspconfig** - LSP configuration
- **mason.nvim** - LSP/DAP/linter installer
- **mason-lspconfig.nvim** - Bridge mason ↔ lspconfig
- **nvim-cmp** - Completion engine
- **cmp-nvim-lsp** - LSP completion source
- **cmp-buffer** - Buffer completion source
- **cmp-path** - Path completion source
- **cmp-cmdline** - Command line completion
- **LuaSnip** - Snippet engine
- **friendly-snippets** - Snippet collection
- **lspkind.nvim** - LSP kind icons
- **neoconf.nvim** - Project-local LSP settings
- **lazydev.nvim** - Enhanced Lua LSP for Neovim
- **lsp_signature.nvim** - Signature help
- **aerial.nvim** - Symbol outline
- **nvim-lsp-file-operations** - File ops with LSP support

### Syntax & Editing
- **nvim-treesitter** - Syntax highlighting
- **nvim-ts-autotag** - Auto close/rename HTML tags
- **nvim-ts-context-commentstring** - Context-aware comments
- **nvim-autopairs** - Auto close brackets
- **Comment.nvim** - Smart commenting
- **mini.bufremove** - Better buffer deletion
- **vim-surround** - Surround text objects

### Navigation
- **snacks.nvim** - QoL plugins collection with picker (fuzzy finder)
- **neo-tree.nvim** - File explorer
- **which-key.nvim** - Keybinding hints

### UI
- **catppuccin** - Color scheme
- **noice.nvim** - Better UI (LSP overrides disabled)
- **nvim-notify** - Notification manager
- **alpha-nvim** - Dashboard
- **indent-blankline.nvim** - Indent guides
- **vim-illuminate** - Highlight word under cursor
- **dressing.nvim** - Better vim.ui
- **nvim-web-devicons** - File icons
- **todo-comments.nvim** - Highlight TODOs
- **nvim-colorizer.lua** - Color previews
- **nvim-ufo** - Better folding

### Git
- **gitsigns.nvim** - Git decorations
- **lazygit.nvim** - LazyGit integration
- **diffview.nvim** - Git diff viewer
- **git-conflict.nvim** - Conflict resolver

### AI
- **copilot.lua** - GitHub Copilot
- **copilot-cmp** - Copilot completion source
- **CopilotChat.nvim** - Copilot chat (Claude 3.7 Sonnet)

### Terminal
- **toggleterm.nvim** - Terminal manager

### Language-Specific
- **gopher.nvim** (Go)
- **nvim-dap-go** (Go debugging)
- **nvim-dap-python** (Python debugging)
- **rustaceanvim** (Rust)
- **crates.nvim** (Rust dependencies)
- **nvim-vtsls** (TypeScript)
- **tsc.nvim** (TypeScript compiler)
- **package-info.nvim** (Node.js packages)
- **schemastore.nvim** (JSON/YAML schemas)

## Configuration

### Options (vim.opt)

Key settings in `lua/config/options.lua`:
- Line numbers enabled
- Relative line numbers
- 2-space indentation
- Smart indentation
- Case-insensitive search (smart case)
- Split windows open below/right
- Persistent undo
- Faster updatetime (250ms)
- True color support

### Autocommands

Defined in `lua/config/autocmds.lua`:
- Highlight on yank
- Remove trailing whitespace on save
- Auto create parent directories
- Restore cursor position
- Resize splits on window resize
- Close certain filetypes with `q`

### File Permissions

When creating new files, use standard Unix permissions:
- **Regular files**: `644` (rw-r--r--) - Owner can read/write, others can read
- **NOT** `600` (rw-------) unless the file contains sensitive data (credentials, keys, etc.)

This ensures proper file accessibility while maintaining security for sensitive files.

## Troubleshooting

### Common Issues

#### "Invalid 'data': Cannot convert given Lua table" Error

**Cause:** noice.nvim LSP overrides conflict with LSP configuration.

**Solution:** LSP overrides are disabled in noice.nvim configuration:
```lua
-- lua/plugins/ui.lua:228-232
lsp = {
  override = {
    ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
    ["vim.lsp.util.stylize_markdown"] = false,
    ["cmp.entry.get_documentation"] = false,
  },
},
```

#### LSP Server Not Starting

Check:
1. `:LspInfo` - Shows attached servers
2. `:Mason` - Verify server is installed
3. `:checkhealth` - Check for issues
4. Server in `ensure_installed` list in `lua/plugins/lsp.lua:31-50`

#### Treesitter Highlighting Not Working

Check:
1. `:TSInstallInfo` - Shows installed parsers
2. Parser in `ensure_installed` list in `lua/plugins/treesitter.lua`
3. Run `:TSInstall <language>` manually

#### Completion Not Working

Check:
1. LSP is attached (`:LspInfo`)
2. Copilot is authorized (`:Copilot auth`)
3. nvim-cmp sources configured in `lua/plugins/completion.lua:86-92`

### Health Checks

Run `:checkhealth` to diagnose issues:
```vim
:checkhealth
:checkhealth lazy
:checkhealth lspconfig
:checkhealth mason
:checkhealth nvim-treesitter
```

## Migration Notes

This configuration was migrated from AstroNvim v5.3.14 to standalone lazy.nvim.

### Key Differences from AstroNvim

| AstroNvim | Standalone |
|-----------|------------|
| `astrocore.mappings` | `vim.keymap.set()` + which-key |
| `astrolsp` | nvim-lspconfig + mason-lspconfig |
| `astroui` | Direct colorscheme + UI plugins |
| `astrocommunity` | Manual plugin specs per language |
| `options = { opt = { ... } }` | `vim.opt.setting = value` |

### Removed Dependencies
- AstroNvim framework
- astrocore
- astrolsp
- astroui
- astrocommunity

### Maintained Features
- All LSP functionality
- All language packs (22+ languages)
- All custom keymaps
- Copilot integration
- Neo-tree GitHub URL generation
- Format on save
- Inlay hints and codelens

## Performance

Target startup time: <50ms

Profile startup with:
```vim
:Lazy profile
```

## Customization

### Adding a New Language

1. Add parser to `lua/plugins/treesitter.lua`:
```lua
ensure_installed = {
  -- ... existing parsers
  "newlang",
}
```

2. Add LSP server to `lua/plugins/lsp.lua`:
```lua
ensure_installed = {
  -- ... existing servers
  "newlang_ls",
}
```

3. Optionally create `lua/plugins/lang/newlang.lua` for language-specific plugins

### Adding Custom Keymaps

Add to `lua/config/keymaps.lua`:
```lua
vim.keymap.set("n", "<leader>x", "<cmd>SomeCommand<cr>", { desc = "Description" })
```

Or register with which-key in the same file.

### Changing Colorscheme

Edit `lua/plugins/colorscheme.lua`:
```lua
return {
  {
    "your-preferred/colorscheme",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("your-colorscheme")
    end,
  },
}
```

## References

- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [AstroNvim](https://github.com/AstroNvim/AstroNvim) (original inspiration)

## License

This configuration is based on AstroNvim v5.3.14 and follows the same GPL-3.0 license principles.

---

Last updated: 2025-12-31
Neovim version: 0.10+
