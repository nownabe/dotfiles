return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    options = {
      opt = {
        relativenumber = false,
        spell = true,
        wrap = true,
        titlestring = "%{v:lua.nvim_title()}",
      },
    },
  },
  config = function(_, opts)
    require("astrocore").setup(opts)
    vim.diagnostic.config({
      virtual_text = false,
      virtual_lines = true,
    })

    function _G.nvim_title()
      local filepath = vim.fn.expand("%:p")
      if filepath == "" then return "\u{e7c5} [No Name]" end
      local dir = vim.fn.expand("%:p:h")
      local found = vim.fs.find(".git", { upward = true, path = dir })
      if #found > 0 then
        local root = vim.fn.fnamemodify(found[1], ":h") .. "/"
        if filepath:sub(1, #root) == root then return "\u{e7c5} " .. filepath:sub(#root + 1) end
      end
      return "\u{e7c5} " .. vim.fn.expand("%:t")
    end
  end,
}
