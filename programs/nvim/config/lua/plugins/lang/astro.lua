-- Astro language support
-- LSP: astro

return {
  {
    "AstroNvim/astrolsp",
    optional = true,
    opts = function(_, opts)
      opts.servers = require("astrocore").list_insert_unique(opts.servers or {}, { "astro" })
    end,
  },
  {
    "AstroNvim/astrocore",
    optional = true,
    ---@type AstroCoreOpts
    opts = {
      treesitter = { ensure_installed = { "astro" } },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "astro" })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
        "astro-language-server",
      })
    end,
  },
}
