# Language Support

This directory contains self-contained language configurations for Neovim. Each language file manages its own Treesitter parsers, LSP servers, and language-specific plugins.

## Architecture

### Self-Contained Language Files

Each language file follows a consistent pattern:

```lua
-- Language Name Support
return {
  -- 1. Extend treesitter (parser installation)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "parser_name" })
    end,
  },

  -- 2. Extend mason-lspconfig (LSP server installation)
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "lsp_server_name" })
    end,
  },

  -- 3. LSP configuration (server setup)
  {
    "neovim/nvim-lspconfig",
    opts = {},
    config = function()
      local lsp_utils = require("utils.lsp")
      require("lspconfig").lsp_server_name.setup({
        capabilities = lsp_utils.get_capabilities(),
        on_attach = lsp_utils.on_attach,
        settings = {
          -- Language-specific settings
        },
      })
    end,
  },

  -- 4. Language-specific plugins (optional)
  -- { "author/plugin-name", ... },
}
```

### Common Utilities

All language files use shared utilities from `utils/lsp.lua`:

- **`get_capabilities()`**: Returns default LSP capabilities with nvim-cmp support
- **`on_attach(client, bufnr)`**: Sets up keymaps, enables inlay hints and codelens

### Benefits

- **Self-contained**: Each language file can be added/removed independently
- **No core modifications**: Adding a new language doesn't require editing core files
- **Clear organization**: Easy to find and modify language-specific configurations
- **Consistent pattern**: All language files follow the same structure

## Language Files

### Complex Languages

Languages with custom LSP configurations, plugins, or debugging support:

#### `lua.lua`
- **Parsers**: lua
- **LSP**: lua_ls
  - Recognizes `vim` global
  - Includes Neovim runtime paths
  - Inlay hints enabled
- **Plugins**:
  - lazydev.nvim: Enhanced Lua LSP for Neovim development
  - luvit-meta: Type definitions for luvit

#### `go.lua`
- **Parsers**: go, gomod, gosum, gowork
- **LSP**: gopls
  - Static analysis with staticcheck
  - gofumpt formatting
  - Inlay hints for types and parameters
- **Plugins**:
  - gopher.nvim: Go development utilities
  - nvim-dap-go: Debugging support

#### `python.lua`
- **Parsers**: python
- **LSP**: pyright, ruff_lsp
  - Type checking with pyright
  - Linting/formatting with ruff
- **Plugins**:
  - nvim-dap-python: Debugging support

#### `rust.lua`
- **Parsers**: rust
- **LSP**: rust_analyzer (managed by rustaceanvim)
- **Plugins**:
  - rustaceanvim: Enhanced Rust support (manages rust_analyzer internally)
  - crates.nvim: Cargo.toml dependency management

#### `typescript.lua`
- **Parsers**: typescript, tsx, javascript
- **LSP**: ts_ls, eslint
  - Formatting disabled (use prettier)
  - Inlay hints for parameters and types
- **Plugins**:
  - typescript-tools.nvim: Enhanced TypeScript support
  - package-info.nvim: package.json dependency management

#### `markdown.lua`
- **Parsers**: markdown, markdown_inline
- **LSP**: marksman (uses default handler)
- **Plugins**:
  - render-markdown.nvim: Better markdown rendering

### Simple Languages

#### `languages.lua`

Consolidated file for languages with standard LSP configurations:

- **Parsers**: bash, dockerfile, html, css, json, yaml, toml, terraform, hcl, astro, proto, ruby, mdx, scss
- **LSP Servers**:
  - bashls (Bash)
  - dockerls (Docker)
  - html (HTML)
  - cssls (CSS)
  - emmet_ls (HTML/CSS expansion)
  - jsonls (JSON) - with schemastore integration
  - yamlls (YAML) - with schemastore integration
  - taplo (TOML)
  - terraformls, tflint (Terraform)
  - astro (Astro)
  - tailwindcss (Tailwind CSS) - with custom classRegex
  - solargraph (Ruby)
- **Plugins**:
  - schemastore.nvim: JSON/YAML schema validation
  - chezmoi.vim: Chezmoi dotfile support
  - vim-cue: CUE language support
  - vim-rego: OPA Rego language support

## Adding a New Language

### Simple Language (Standard LSP)

If the language has a standard LSP server with no special configuration, add it to `languages.lua`:

```lua
-- Add parser
vim.list_extend(opts.ensure_installed, {
  -- ... existing parsers
  "newlang",
})

-- Add LSP server
vim.list_extend(opts.ensure_installed, {
  -- ... existing servers
  "newlang_ls",
})

-- LSP will use the default handler from lua/plugins/lsp.lua
```

### Complex Language (Custom Configuration)

If the language requires custom LSP settings or plugins, create a new file `newlang.lua`:

```lua
-- NewLang Language Support
return {
  -- Extend treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "newlang" })
    end,
  },

  -- Extend mason-lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "newlang_ls" })
    end,
  },

  -- LSP configuration
  {
    "neovim/nvim-lspconfig",
    opts = {},
    config = function()
      local lsp_utils = require("utils.lsp")
      require("lspconfig").newlang_ls.setup({
        capabilities = lsp_utils.get_capabilities(),
        on_attach = lsp_utils.on_attach,
        settings = {
          newlang = {
            -- Custom settings here
            feature = true,
          },
        },
      })
    end,
  },

  -- Language-specific plugins (optional)
  {
    "author/newlang-plugin",
    ft = "newlang",
    opts = {},
  },
}
```

### Special Cases

#### Custom on_attach

If you need to modify the on_attach function:

```lua
config = function()
  local lsp_utils = require("utils.lsp")
  require("lspconfig").newlang_ls.setup({
    capabilities = lsp_utils.get_capabilities(),
    on_attach = function(client, bufnr)
      -- Custom modifications
      client.server_capabilities.documentFormattingProvider = false
      -- Call standard on_attach
      lsp_utils.on_attach(client, bufnr)
    end,
    settings = { ... },
  })
end,
```

#### Plugin-Managed LSP

Some plugins manage their LSP server internally (e.g., rustaceanvim):

```lua
-- Rust Language Support
return {
  -- Treesitter parser
  { "nvim-treesitter/nvim-treesitter", opts = ... },

  -- NO mason-lspconfig or lspconfig setup needed
  -- rustaceanvim manages rust_analyzer internally
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    lazy = false,
    ft = { "rust" },
    opts = {
      server = {
        -- rust_analyzer settings here
      },
    },
  },
}
```

## Core Files

Language files work alongside these core configuration files:

### `lua/plugins/treesitter.lua`
- Contains only core parsers: vim, vimdoc, query, regex, git-related
- Language files extend this via `opts` function

### `lua/plugins/lsp.lua`
- Contains only common infrastructure:
  - mason.nvim setup
  - mason-lspconfig with empty `ensure_installed`
  - Default handler for servers without custom config
- Language files extend mason-lspconfig and add custom handlers

### `lua/utils/lsp.lua`
- Common utilities used by all language files:
  - `get_capabilities()`: LSP capabilities with nvim-cmp support
  - `on_attach()`: Keymaps, inlay hints, codelens

## Troubleshooting

### LSP Server Not Starting

1. Check if the server is installed: `:Mason`
2. Check if the server is attached: `:LspInfo`
3. Verify the server is in the language file's `ensure_installed` list
4. Check for errors: `:checkhealth mason`

### Parser Not Working

1. Check if parser is installed: `:TSInstallInfo`
2. Verify the parser is in the language file's `ensure_installed` list
3. Manually install: `:TSInstall <language>`

### Custom Settings Not Applied

1. Ensure you're editing the correct language file
2. Verify the settings structure matches the LSP server's requirements
3. Check LSP logs: `:LspLog`
4. Restart Neovim after configuration changes

## Migration from Core Files

If you need to migrate a language from core files to a self-contained file:

1. **Identify** what to move:
   - Treesitter parser from `treesitter.lua`
   - LSP server from `lsp.lua` `ensure_installed`
   - LSP setup_handler from `lsp.lua` if exists
   - Related plugins

2. **Create** new language file with all components

3. **Remove** from core files:
   - Parser from `treesitter.lua`
   - LSP server from `lsp.lua` `ensure_installed`
   - Custom handler from `lsp.lua` `setup_handlers`

4. **Test** with `:LspInfo` and `:TSInstallInfo`

## Examples

See existing language files for complete examples:
- Simple: `languages.lua`
- Custom LSP: `lua.lua`, `go.lua`, `python.lua`, `typescript.lua`
- Plugin-managed LSP: `rust.lua`
- Custom plugins: `markdown.lua`
