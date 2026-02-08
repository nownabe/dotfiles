return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    opts.filesystem.filtered_items = {
      visible = true,
      hide_dotfiles = false,
      hide_gitignored = false,
    }
    opts.sources = { "filesystem" }
    opts.source_selector = { winbar = false }
    opts.window.mappings["s"] = false
    opts.window.mappings["S"] = false
    opts.window.mappings["t"] = false
    opts.window.mappings["w"] = false
    opts.window.mappings["<C-h>"] = "open_split"
    opts.window.mappings["<C-v>"] = "open_vsplit"
    opts.commands = opts.commands or {}
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
      }

      -- Add GitHub URL options if in a git repo
      vim.fn.system("git rev-parse --is-inside-work-tree")
      if vim.v.shell_error == 0 then
        local git_root = vim.trim(vim.fn.system("git rev-parse --show-toplevel"))
        local rel_path = filepath:sub(#git_root + 2)
        local remote_url = vim.trim(vim.fn.system("git remote get-url origin"))
        remote_url = remote_url:gsub("^ssh://git@", "https://")
        remote_url = remote_url:gsub("^git@(.+):", "https://%1/")
        remote_url = remote_url:gsub("%.git$", "")
        local commit = vim.trim(vim.fn.system("git rev-parse HEAD"))
        local branch = vim.trim(vim.fn.system("git rev-parse --abbrev-ref origin/HEAD")):gsub("^origin/", "")
        vals["GITHUB (commit)"] = remote_url .. "/blob/" .. commit .. "/" .. rel_path
        vals["GITHUB (default branch)"] = remote_url .. "/blob/" .. branch .. "/" .. rel_path
      end

      local options = vim.tbl_filter(function(val) return vals[val] ~= "" end, vim.tbl_keys(vals))
      if vim.tbl_isempty(options) then
        vim.notify("No values to copy", vim.log.levels.WARN)
        return
      end
      table.sort(options)
      vim.ui.select(options, {
        prompt = "Choose to copy to clipboard:",
        format_item = function(item) return ("%s: %s"):format(item, vals[item]) end,
      }, function(choice)
        local result = vals[choice]
        if result then
          vim.notify(("Copied: `%s`"):format(result))
          vim.fn.setreg("+", result)
        end
      end)
    end
  end,
}
