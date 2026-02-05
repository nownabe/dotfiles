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
- **Git**: gitsigns.nvim

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
│   │       ├── languages.lua         # Consolidated simple languages (22+ languages)
│   │       ├── go.lua                # Complex: DAP + gopher.nvim + custom keymaps
│   │       ├── lua.lua               # Complex: lazydev + lua_ls config
│   │       ├── markdown.lua          # Complex: render-markdown plugin
│   │       ├── python.lua            # Complex: DAP + pyright + ruff_lsp
│   │       ├── rust.lua              # Complex: rustaceanvim + crates.nvim
│   │       └── typescript.lua        # Complex: typescript-tools + package-info
│   └── utils/
│       ├── init.lua                  # Helper functions
│       └── lsp.lua                   # Common LSP utilities (capabilities, on_attach)
└── AGENTS.md                         # This file
```

## Features

### Core Features
- ✅ LSP support for 22+ languages
- ✅ Treesitter syntax highlighting
- ✅ Intelligent code completion with Copilot
- ✅ Fuzzy finding with Snacks Picker
- ✅ File explorer with Neo-tree
- ✅ Git integration with gitsigns
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

### Architecture

The LSP configuration follows a **self-contained language file architecture**:

- **Core files**: Contain only infrastructure (`treesitter.lua`, `lsp.lua`)
- **Language files**: Each file manages its own parsers, LSP servers, and plugins
- **Common utilities**: Shared LSP functions in `utils/lsp.lua`

For detailed architecture and language-specific configurations, see [lua/plugins/lang/README.md](lua/plugins/lang/README.md).

### Installed Servers

All LSP servers are managed in their respective language files in `lua/plugins/lang/`:

- **Complex languages**: lua.lua, go.lua, python.lua, rust.lua, typescript.lua, markdown.lua
- **Simple languages**: languages.lua (bash, docker, html, css, json, yaml, toml, terraform, ruby, astro, tailwind, etc.)

### Custom Configurations

Some languages have custom LSP configurations:

- **lua_ls**: Neovim development support with lazydev.nvim
- **gopls**: gofumpt formatting, staticcheck, inlay hints
- **ts_ls**: Formatting disabled (use prettier), inlay hints
- **jsonls/yamlls**: Schema validation with schemastore
- **rust_analyzer**: Managed by rustaceanvim

See [lua/plugins/lang/README.md](lua/plugins/lang/README.md) for detailed configurations.

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

### AI
- **copilot.lua** - GitHub Copilot
- **copilot-cmp** - Copilot completion source
- **CopilotChat.nvim** - Copilot chat (Claude 3.7 Sonnet)

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

## Development Workflow

### GitHub Issues

Track configuration changes using GitHub Issues in the `nownabe/dotfiles` repository.

#### Issue Structure

**Labels:**
- `nvim` - For all Neovim configuration issues

**Assignee:**
- `nownabe` - Assign to yourself for tracking

**Title Format:**
- `Add [feature/language/plugin]`
- `Fix [issue description]`
- `Refactor [component]`
- `Migrate [component] to [new approach]`

**Body Template:**
```markdown
## Goal

[Brief description of what needs to be done]

## Context

[Background information, why this change is needed, current situation]

## Solution

### Proposed Solution

[Describe the approach to solve the problem]

### Rationale

[Why this solution is appropriate]

### Alternatives Considered

[Other approaches that were considered and why they weren't chosen]

## Expected Impact

[Expected benefits, potential risks, affected components]

## Tasks

### Implementation Steps

- [ ] Step 1
- [ ] Step 2
- [ ] Test changes
- [ ] Update documentation

### Files

- `path/to/file.lua` (create/update/remove)

## Notes

[Any special considerations, dependencies, or technical details]
```

#### Creating Issues with gh CLI

```bash
# Create issue
gh issue create \
  --title "Add feature" \
  --body-file issue_template.md \
  --label nvim \
  --assignee nownabe

# Or interactively
gh issue create --label nvim --assignee nownabe
```

#### Example: Language Support

```markdown
Title: Add Zig language support

## Goal

Add full language support for Zig including LSP and Treesitter.

## Context

Currently working on Zig projects but lack proper IDE features like syntax highlighting,
code completion, and diagnostics. Need to add Zig language support following the
self-contained language file architecture.

## Solution

### Proposed Solution

Create a new self-contained language file `lua/plugins/lang/zig.lua` that manages:
- Treesitter parser for syntax highlighting
- LSP server (zls) for language intelligence
- LSP configuration with Zig-specific settings

### Rationale

Follows the established self-contained language file pattern, keeping all Zig-related
configuration in one place without modifying core files.

### Alternatives Considered

- Adding to `languages.lua`: Not suitable as zls requires custom configuration
- Central configuration: Rejected in favor of self-contained approach (Issue #11)

## Expected Impact

**Benefits:**
- Syntax highlighting for .zig files
- Code completion and diagnostics
- Go-to-definition and hover documentation

**Risks:**
- zls may require specific build configuration
- First time adding this language, may need adjustments

**Affected Components:**
- New file: `lua/plugins/lang/zig.lua`

## Tasks

### Implementation Steps

- [ ] Create `lua/plugins/lang/zig.lua`
- [ ] Add Treesitter parser: `zig`
- [ ] Add LSP server: `zls` via mason-lspconfig
- [ ] Configure zls settings (build options, semantic tokens)
- [ ] Test LSP attachment (`:LspInfo`)
- [ ] Test Treesitter highlighting (`:TSInstallInfo`)
- [ ] Test basic features (completion, diagnostics, hover)
- [ ] Update documentation if needed

### Files

- `lua/plugins/lang/zig.lua` (create)

## Notes

- zls requires special build configuration settings for proper project detection
- Zig 0.11+ recommended for best LSP experience
- May need to configure build.zig path in settings
```

#### Workflow

1. **Create issue** for the work
2. **Work incrementally** with frequent testing
3. **Test thoroughly** with appropriate health checks
4. **Close issue** with reference in commit message (e.g., `Fixes #123`)

#### Recent Issues

Examples from the language configuration refactoring:
- Issue #11: Core infrastructure verification
- Issue #12: Lua language migration
- Issue #13: Go language migration
- Issue #18: LSP keymap refactoring
- Issue #19: Simple languages migration

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

1. `:LspInfo` - Shows attached servers
2. `:Mason` - Verify server is installed
3. `:checkhealth mason` - Check for issues
4. Verify server in the appropriate language file

See [lua/plugins/lang/README.md](lua/plugins/lang/README.md#troubleshooting) for details.

#### Treesitter Highlighting Not Working

1. `:TSInstallInfo` - Shows installed parsers
2. Verify parser in the appropriate language file
3. Run `:TSInstall <language>` manually

See [lua/plugins/lang/README.md](lua/plugins/lang/README.md#troubleshooting) for details.

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

### Recent Refactoring (2026-01-04)

**Language Configuration Deduplication**: Migrated from centralized configuration to self-contained language files.

**Before:**
- `treesitter.lua`: 46 parsers (all languages)
- `lsp.lua`: 17 LSP servers in `ensure_installed`, 7 `setup_handlers`
- Language files: Only language-specific plugins

**After:**
- `treesitter.lua`: 10 core parsers only (vim, vimdoc, query, regex, git-related)
- `lsp.lua`: Empty `ensure_installed`, 1 default handler only
- Language files: Self-contained (parsers + LSP + plugins)
- `utils/lsp.lua`: Common utilities (`get_capabilities()`, `on_attach()`)

**Benefits:**
- Each language file is self-contained and can be added/removed independently
- No need to modify core files when adding new languages
- Better organization and maintainability
- Clear separation between infrastructure and language-specific code

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

Language configurations are self-contained in `lua/plugins/lang/`. Each language file manages its own Treesitter parsers, LSP servers, and plugins.

For detailed instructions and examples, see [lua/plugins/lang/README.md](lua/plugins/lang/README.md).

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

Last updated: 2026-01-04
Neovim version: 0.10+
