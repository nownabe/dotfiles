-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.
--
-- https://github.com/AstroNvim/astrocommunity

---@type LazySpec
return {
  "AstroNvim/astrocommunity",

  -- pack
  { import = "astrocommunity.pack.astro" },
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.pack.chezmoi" },
  { import = "astrocommunity.pack.go" },
  { import = "astrocommunity.pack.html-css" },
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.cue" },
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.markdown" },
  { import = "astrocommunity.pack.mdx" },
  { import = "astrocommunity.pack.proto" },
  { import = "astrocommunity.pack.python-ruff" },
  { import = "astrocommunity.pack.rego" },
  { import = "astrocommunity.pack.ruby" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.tailwindcss" },
  { import = "astrocommunity.pack.terraform" },
  { import = "astrocommunity.pack.toml" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.yaml" },
}
