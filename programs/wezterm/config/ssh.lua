local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

function M.apply_to_config(config)
  -- Generate SSH domains from .ssh/config
  local ssh_domains = wezterm.default_ssh_domains()
  for _, domain in ipairs(ssh_domains) do
    domain.assume_shell = "Posix"
  end
  config.ssh_domains = ssh_domains

  -- Ctrl+Shift+A: Attach to SSH host
  table.insert(config.keys, {
    key = "a",
    mods = "CTRL|SHIFT",
    action = wezterm.action_callback(function(window, pane)
      local hosts = wezterm.enumerate_ssh_hosts()

      local choices = {}
      for host, _ in pairs(hosts) do
        table.insert(choices, { label = host, id = host })
      end
      table.sort(choices, function(a, b)
        return a.label < b.label
      end)

      if #choices == 0 then
        window:toast_notification(
          "WezTerm",
          "No SSH hosts found. Create ~/.ssh/config to define hosts.",
          nil,
          4000
        )
        return
      end

      window:perform_action(
        act.InputSelector({
          title = "Connect to SSH host",
          choices = choices,
          fuzzy = true,
          action = wezterm.action_callback(function(inner_window, inner_pane, id, _)
            if id then
              inner_window:perform_action(
                act.Multiple({
                  act.AttachDomain("SSH:" .. id),
                }),
                inner_pane
              )
            end
          end),
        }),
        pane
      )
    end),
  })

  -- Ctrl+Shift+D: Detach current domain
  table.insert(config.keys, {
    key = "d",
    mods = "CTRL|SHIFT",
    action = act.DetachDomain("CurrentPaneDomain"),
  })
end

return M
