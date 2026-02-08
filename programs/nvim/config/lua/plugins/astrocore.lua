return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    options = {
      opt = {
        relativenumber = false,
        spell = true,
      },
    },
  },
  config = function(_, opts)
    require("astrocore").setup(opts)
    vim.diagnostic.config {
      virtual_text = false,
      virtual_lines = true,
    }
  end,
}
