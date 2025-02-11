-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.
-- 
-- https://github.com/AstroNvim/astrocommunity

---@type LazySpec
return {
  "AstroNvim/astrocommunity",

  -- pack
  { import = "astrocommunity.pack.go" },
  { import = "astrocommunity.pack.lua" },
}
