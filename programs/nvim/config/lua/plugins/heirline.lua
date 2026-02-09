-- Catppuccin Mocha palette
local mantle = "#181825"
local surface0 = "#313244"

return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    -- Set bg on tabline root so file icons (which don't use get_attributes)
    -- inherit it via heirline's hl merge chain
    if opts.tabline then
      opts.tabline.hl = { bg = mantle }
    end
  end,
}
