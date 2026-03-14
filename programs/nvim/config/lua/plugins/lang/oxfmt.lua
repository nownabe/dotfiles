-- Oxfmt formatter (via conform.nvim)
-- Supports: JS, TS, JSON, YAML, HTML, CSS, SCSS, Markdown, MDX, TOML, GraphQL, Vue

return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        javascript = { "oxfmt" },
        javascriptreact = { "oxfmt" },
        typescript = { "oxfmt" },
        typescriptreact = { "oxfmt" },
        json = { "oxfmt" },
        jsonc = { "oxfmt" },
        yaml = { "oxfmt" },
        html = { "oxfmt" },
        css = { "oxfmt" },
        scss = { "oxfmt" },
        less = { "oxfmt" },
        markdown = { "oxfmt" },
        mdx = { "oxfmt" },
        toml = { "oxfmt" },
        graphql = { "oxfmt" },
        vue = { "oxfmt" },
      },
    },
  },
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
