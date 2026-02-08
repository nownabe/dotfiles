return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    if opts.tabline then
      local mocha = require("catppuccin.palettes").get_palette("mocha")
      opts.tabline.hl = { underline = true, sp = mocha.surface0 }
    end
  end,
}
