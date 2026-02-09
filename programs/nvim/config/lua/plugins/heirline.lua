return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    -- Set underline on tabline root so all children inherit it
    if opts.tabline then
      opts.tabline.hl = { underline = true, sp = "#313244" }
    end

    -- Monkey-patch eval_hl to force sp on every underlined highlight.
    -- This bypasses any inheritance/merge issues: heirline's final
    -- highlight creation always gets the correct sp color.
    local hi = require("heirline.highlights")
    local orig_eval_hl = hi.eval_hl
    function hi.eval_hl(hl)
      if type(hl) == "table" and hl.underline then
        hl = vim.tbl_extend("force", hl, { sp = "#313244" })
      end
      return orig_eval_hl(hl)
    end
  end,
}
