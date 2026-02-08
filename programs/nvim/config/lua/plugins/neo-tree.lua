return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    opts.filesystem.filtered_items = {
      visible = true,
      hide_dotfiles = false,
      hide_gitignored = false,
    }
    opts.window.mappings["<C-h>"] = "open_split"
    opts.window.mappings["<C-v>"] = "open_vsplit"
    opts.window.mappings["Y"] = "copy_github_url"
    opts.commands = opts.commands or {}
    opts.commands.copy_github_url = function(state)
      local node = state.tree:get_node()
      local filepath = node:get_id()
      local git_root = vim.trim(vim.fn.system("git rev-parse --show-toplevel"))
      local rel_path = filepath:sub(#git_root + 2)
      local remote_url = vim.trim(vim.fn.system("git remote get-url origin"))
      remote_url = remote_url:gsub("^ssh://git@", "https://")
      remote_url = remote_url:gsub("^git@(.+):", "https://%1/")
      remote_url = remote_url:gsub("%.git$", "")
      vim.ui.select({ "Permalink (commit)", "Default branch" }, { prompt = "Copy GitHub URL" }, function(choice)
        if not choice then return end
        local ref
        if choice == "Permalink (commit)" then
          ref = vim.trim(vim.fn.system("git rev-parse HEAD"))
        else
          ref = vim.trim(vim.fn.system("git rev-parse --abbrev-ref origin/HEAD")):gsub("^origin/", "")
        end
        local url = remote_url .. "/blob/" .. ref .. "/" .. rel_path
        vim.fn.setreg("+", url)
        vim.notify("Copied: " .. url)
      end)
    end
  end,
}
