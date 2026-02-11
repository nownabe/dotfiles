local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

function M.apply_to_config(config)
  config.leader = { key = "x", mods = "CTRL", timeout_milliseconds = 2000 }

  config.keys = {
    -- Pass through Ctrl+X to shell (e.g. Ctrl+X Ctrl+E for edit-command-line)
    { key = "x", mods = "LEADER", action = act.SendKey({ key = "x", mods = "CTRL" }) },

    -- Pane splits
    { key = "\\", mods = "LEADER", action = act.SplitPane({ direction = "Down" }) },
    { key = "|", mods = "LEADER|SHIFT", action = act.SplitPane({ direction = "Right" }) },

    -- Pane resize mode
    { key = "r", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },

    -- Pane focus
    { key = "h", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
    { key = "j", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },
    { key = "k", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
    { key = "l", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },

    -- Tab navigation
    { key = "h", mods = "ALT", action = act.ActivateTabRelative(-1) },
    { key = "l", mods = "ALT", action = act.ActivateTabRelative(1) },
    { key = "n", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },

    -- Workspace (session) navigation
    { key = "j", mods = "ALT", action = act.SwitchWorkspaceRelative(1) },
    { key = "k", mods = "ALT", action = act.SwitchWorkspaceRelative(-1) },
    { key = "s", mods = "ALT", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
    {
      key = "n",
      mods = "LEADER",
      action = act.PromptInputLine({
        description = "Enter name for new workspace",
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            window:perform_action(act.SwitchToWorkspace({ name = line }), pane)
          end
        end),
      }),
    },

    -- Clipboard
    { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
    { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },

    -- Copy mode & search
    { key = "Space", mods = "CTRL|SHIFT", action = act.ActivateCopyMode },
    { key = "f", mods = "CTRL|SHIFT", action = act.Search("CurrentSelectionOrEmptyString") },
  }

  config.key_tables = {
    resize_pane = {
      { key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
      { key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
      { key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
      { key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },
      { key = "Escape", action = "PopKeyTable" },
    },
  }
end

return M
