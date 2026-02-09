return {
  "windwp/nvim-autopairs",
  config = function(plugin, opts)
    require("astronvim.plugins.configs.nvim-autopairs")(plugin, opts)

    local Rule = require("nvim-autopairs.rule")
    local cond = require("nvim-autopairs.conds")
    local npairs = require("nvim-autopairs")

    npairs.add_rules({
      Rule("$", "$", { "tex", "latex", "plaintex", "markdown" })
        :with_pair(cond.not_after_regex("%%"))
        :with_move(cond.after_text("$"))
        :with_del(cond.done()),
    })
  end,
}
