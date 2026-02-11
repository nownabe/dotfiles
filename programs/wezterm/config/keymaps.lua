local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

function M.apply_to_config(config)
  config.leader = { key = "x", mods = "CTRL", timeout_milliseconds = 2000 }

  config.keys = {
    -- Pass through Ctrl+X to shell (e.g. Ctrl+X Ctrl+E for edit-command-line)
    { key = "x",  mods = "LEADER", action = act.SendKey({ key = "x", mods = "CTRL" }) },

    -- Pane splits
    { key = "\\", mods = "LEADER", action = act.SplitPane({ direction = "Down" }) },
    { key = "|",  mods = "LEADER", action = act.SplitPane({ direction = "Right" }) },

    -- Pane resize mode
    {
      key = "r",
      mods = "LEADER",
      action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }),
    },

    -- Pane focus
    { key = "h", mods = "ALT",        action = act.ActivatePaneDirection("Left") },
    { key = "j", mods = "ALT",        action = act.ActivatePaneDirection("Down") },
    { key = "k", mods = "ALT",        action = act.ActivatePaneDirection("Up") },
    { key = "l", mods = "ALT",        action = act.ActivatePaneDirection("Right") },

    -- Tab navigation
    { key = "h", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
    { key = "l", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(1) },
    { key = "n", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },

    -- Workspace (session) navigation
    { key = "j", mods = "CTRL|SHIFT", action = act.SwitchWorkspaceRelative(1) },
    { key = "k", mods = "CTRL|SHIFT", action = act.SwitchWorkspaceRelative(-1) },
    {
      key = "s",
      mods = "CTRL|SHIFT",
      action = wezterm.action_callback(function(window, pane)
        local choices = {
          { label = "+ Create new workspace", id = "__new__" },
        }
        for _, name in ipairs(wezterm.mux.get_workspace_names()) do
          table.insert(choices, { label = name, id = name })
        end

        window:perform_action(
          act.InputSelector({
            title = "Switch workspace",
            choices = choices,
            fuzzy = true,
            action = wezterm.action_callback(function(window, pane, id, label)
              if not id then
                return
              end
              if id == "__new__" then
                window:perform_action(
                  act.PromptInputLine({
                    description = "Enter name for new workspace",
                    action = wezterm.action_callback(function(window, pane, line)
                      if line then
                        window:perform_action(act.SwitchToWorkspace({ name = line }), pane)
                      end
                    end),
                  }),
                  pane
                )
              else
                window:perform_action(act.SwitchToWorkspace({ name = id }), pane)
              end
            end),
          }),
          pane
        )
      end),
    },
    {
      key = "r",
      mods = "CTRL|SHIFT",
      action = wezterm.action_callback(function(window, pane)
        window:perform_action(
          act.PromptInputLine({
            description = "Enter new name for workspace: " .. window:active_workspace(),
            action = wezterm.action_callback(function(window, pane, line)
              if line then
                wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
              end
            end),
          }),
          pane
        )
      end),
    },

    -- Clipboard
    { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
    { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },

    -- Copy mode (use / to search within copy mode)
    {
      key = "Space",
      mods = "CTRL|SHIFT",
      action = wezterm.action_callback(function(window, pane)
        window:perform_action(act.ActivateCopyMode, pane)
        window:perform_action(act.CopyMode("ClearSelectionMode"), pane)
        window:perform_action(act.CopyMode("ClearPattern"), pane)
      end),
    },
  }

  -- Vim-like copy mode (defined from scratch for full control)
  local clear_and_close = act.Multiple({
    act.CopyMode("ClearPattern"),
    act.CopyMode("Close"),
  })

  local copy_mode = {
    -- Movement: h j k l
    { key = "h",     mods = "NONE", action = act.CopyMode("MoveLeft") },
    { key = "j",     mods = "NONE", action = act.CopyMode("MoveDown") },
    { key = "k",     mods = "NONE", action = act.CopyMode("MoveUp") },
    { key = "l",     mods = "NONE", action = act.CopyMode("MoveRight") },

    -- Word movement: w b e
    { key = "w",     mods = "NONE", action = act.CopyMode("MoveForwardWord") },
    { key = "b",     mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
    { key = "e",     mods = "NONE", action = act.CopyMode("MoveForwardWordEnd") },

    -- Line movement: 0 ^ $ Enter
    { key = "0",     mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
    { key = "^",     mods = "NONE", action = act.CopyMode("MoveToStartOfLineContent") },
    { key = "$",     mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
    { key = "Enter", mods = "NONE", action = act.CopyMode("MoveToStartOfNextLine") },

    -- Scrollback/viewport: g G H M L
    { key = "g",     mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
    { key = "G",     mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },
    { key = "H",     mods = "NONE", action = act.CopyMode("MoveToViewportTop") },
    { key = "M",     mods = "NONE", action = act.CopyMode("MoveToViewportMiddle") },
    { key = "L",     mods = "NONE", action = act.CopyMode("MoveToViewportBottom") },

    -- Page/half-page scroll: Ctrl+U Ctrl+D Ctrl+B Ctrl+F
    { key = "u",     mods = "CTRL", action = act.CopyMode({ MoveByPage = -0.5 }) },
    { key = "d",     mods = "CTRL", action = act.CopyMode({ MoveByPage = 0.5 }) },
    { key = "b",     mods = "CTRL", action = act.CopyMode("PageUp") },
    { key = "f",     mods = "CTRL", action = act.CopyMode("PageDown") },

    -- Jump to character: f F t T ; ,
    { key = "f",     mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = false } }) },
    { key = "F",     mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = false } }) },
    { key = "t",     mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = true } }) },
    { key = "T",     mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = true } }) },
    { key = ";",     mods = "NONE", action = act.CopyMode("JumpAgain") },
    { key = ",",     mods = "NONE", action = act.CopyMode("JumpReverse") },

    -- Selection (visual mode): v V Ctrl+V o O
    { key = "v",     mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
    { key = "V",     mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Line" }) },
    { key = "v",     mods = "CTRL", action = act.CopyMode({ SetSelectionMode = "Block" }) },
    { key = "o",     mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEnd") },
    { key = "O",     mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },

    -- Yank (copy) and exit: y
    {
      key = "y",
      mods = "NONE",
      action = act.Multiple({
        act.CopyTo("ClipboardAndPrimarySelection"),
        act.CopyMode("ClearPattern"),
        act.CopyMode("Close"),
      }),
    },

    -- Search: / n N
    { key = "/", mods = "NONE",  action = act.Search({ CaseInSensitiveString = "" }) },
    { key = "n", mods = "NONE",  action = act.CopyMode("NextMatch") },
    { key = "N", mods = "SHIFT", action = act.CopyMode("PriorMatch") },
    {
      key = "Escape",
      mods = "NONE",
      action = act.Multiple({ act.CopyMode("ClearPattern"), act.CopyMode("ClearSelectionMode") }),
    },

    -- Exit: q Escape Ctrl+C
    { key = "q", mods = "NONE", action = clear_and_close },
    { key = "c", mods = "CTRL", action = clear_and_close },
  }

  local search_mode = {
    { key = "Enter", mods = "NONE", action = act.CopyMode("AcceptPattern") },
    {
      key = "Escape",
      mods = "NONE",
      action = act.Multiple({ act.CopyMode("ClearPattern"), act.CopyMode("AcceptPattern") }),
    },
    -- { key = "n",      mods = "CTRL", action = act.CopyMode("NextMatch") },
    -- { key = "p",      mods = "CTRL", action = act.CopyMode("PriorMatch") },
  }

  config.key_tables = {
    copy_mode = copy_mode,
    search_mode = search_mode,
    resize_pane = {
      { key = "h",      action = act.AdjustPaneSize({ "Left", 1 }) },
      { key = "l",      action = act.AdjustPaneSize({ "Right", 1 }) },
      { key = "k",      action = act.AdjustPaneSize({ "Up", 1 }) },
      { key = "j",      action = act.AdjustPaneSize({ "Down", 1 }) },
      { key = "Escape", action = "PopKeyTable" },
    },
  }
end

return M
