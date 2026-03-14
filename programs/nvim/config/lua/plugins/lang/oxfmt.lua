-- Oxfmt formatter (LSP-based)
-- Supports: JS, TS, JSON, YAML, HTML, CSS, SCSS, Markdown, MDX, TOML, GraphQL, Vue

vim.lsp.config("oxfmt", {
  cmd = { "oxfmt", "--lsp" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "json",
    "jsonc",
    "yaml",
    "html",
    "css",
    "scss",
    "less",
    "markdown",
    "mdx",
    "toml",
    "graphql",
    "vue",
  },
  root_markers = { ".oxfmtrc.json", "package.json", ".git" },
})
vim.lsp.enable("oxfmt")

return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
        "oxfmt",
      })
    end,
  },
}
