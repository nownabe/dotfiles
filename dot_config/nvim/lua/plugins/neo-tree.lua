local function generate_github_url(node)
  local remote = vim.fn.systemlist("git config --get remote.origin.url")[1] or ""

  -- convert ssh url to https url
  remote = remote:gsub("^ssh://git@", "https://")
  -- local _, host, _, owner, repo = remote:match "^ssh://(git@)?([^:/]+)(:|/)([^/]+)/(.+)$"
  -- if host and owner and repo then
  --   repo = repo:gsub("%.git$", "")
  --   remote = "https://" .. host .. "/" .. owner .. "/" .. repo
  -- end

  remote = remote:gsub("%.git$", "")

  local branch = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1] or "main"

  return remote .. "/blob/" .. branch .. "/" .. vim.fn.fnamemodify(node.path, ":.")
end

return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    local astrocore = require "astrocore"

    opts.window.mappings["<C-h>"] = "open_split"
    opts.window.mappings["<C-v>"] = "open_vsplit"

    -- Modify copy_selector to add GitHub URL
    -- https://github.com/AstroNvim/AstroNvim/blob/87dc70f7761c3e9965315182f0c40bfbd2cbcd0e/lua/astronvim/plugins/neo-tree.lua#L137-L169
    opts.commands.copy_selector = function(state)
      local node = state.tree:get_node()
      local filepath = node:get_id()
      local filename = node.name
      local modify = vim.fn.fnamemodify

      local vals = {
        ["BASENAME"] = modify(filename, ":r"),
        ["EXTENSION"] = modify(filename, ":e"),
        ["FILENAME"] = filename,
        ["PATH (CWD)"] = modify(filepath, ":."),
        ["PATH (HOME)"] = modify(filepath, ":~"),
        ["PATH"] = filepath,
        ["URI"] = vim.uri_from_fname(filepath),
        ["GITHUB"] = generate_github_url(node),
      }

      local options = vim.tbl_filter(function(val) return vals[val] ~= "" end, vim.tbl_keys(vals))
      if vim.tbl_isempty(options) then
        astrocore.notify("No values to copy", vim.log.levels.WARN)
        return
      end
      table.sort(options)
      vim.ui.select(options, {
        prompt = "Choose to copy to clipboard:",
        format_item = function(item) return ("%s: %s"):format(item, vals[item]) end,
      }, function(choice)
        local result = vals[choice]
        if result then
          astrocore.notify(("Copied: `%s`"):format(result))
          vim.fn.setreg("+", result)
        end
      end)
    end
  end,
}
