return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    if opts.tabline then
      opts.tabline.hl = { underline = true, sp = "#313244" }
    end
  end,
}
