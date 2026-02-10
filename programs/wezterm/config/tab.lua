local wezterm = require("wezterm")

-- Catppuccin Mocha palette
local colors = {
  active_bg = "#89b4fa", -- blue
  active_fg = "#1e1e2e", -- base
  inactive_fg = "#6c7086", -- overlay0
  tab_bar_bg = "#181825", -- mantle
}

-- Process name -> { icon, color }
local process_icons = {
  nvim = { icon = "", color = "#a6e3a1" }, -- green
  vim = { icon = "", color = "#a6e3a1" },
  docker = { icon = "", color = "#89b4fa" }, -- blue
  ssh = { icon = "󰣀", color = "#f9e2af" }, -- yellow
  claude = { icon = "󱜚", color = "#cba6f7" }, -- mauve
  node = { icon = "", color = "#a6e3a1" },
  python = { icon = "", color = "#f9e2af" },
  ruby = { icon = "", color = "#f38ba8" }, -- red
  go = { icon = "", color = "#89dceb" }, -- teal
  cargo = { icon = "", color = "#fab387" }, -- peach
  rust = { icon = "", color = "#fab387" },
}

-- Nerd Font half-circle glyphs for pill shape
local LEFT_PILL = ""
local RIGHT_PILL = ""

local function get_process_info(pane)
  local process_name = pane.foreground_process_name:match("([^/\\]+)$") or ""
  local info = process_icons[process_name]
  if info then
    return info.icon, info.color
  end
  return "", colors.active_bg
end

local function get_project_name(cwd_uri)
  if not cwd_uri then
    return nil
  end

  local cwd = cwd_uri:match("^file://[^/]*(/.*)") or cwd_uri
  -- Match src/github.com/<org>/<project>
  local project = cwd:match("/src/github%.com/[^/]+/([^/]+)")
  if project then
    return project
  end
  -- Fallback: last directory component
  return cwd:match("([^/]+)/?$")
end

local function format_tab(tab, max_width)
  local pane = tab.active_pane
  local icon, icon_color = get_process_info(pane)
  local title = get_project_name(pane.current_working_dir) or "~"

  -- Zoom indicator
  local zoom = ""
  for _, p in ipairs(tab.panes) do
    if p.is_zoomed then
      zoom = " 󰍉"
      break
    end
  end

  local tab_text = icon .. " " .. title .. zoom

  -- Truncate if too long (account for pill glyphs)
  local text_max = max_width - 4
  if #tab_text > text_max then
    tab_text = tab_text:sub(1, text_max - 1) .. "…"
  end

  if tab.is_active then
    return {
      { Foreground = { Color = colors.active_bg } },
      { Background = { Color = colors.tab_bar_bg } },
      { Text = LEFT_PILL },
      { Foreground = { Color = colors.active_fg } },
      { Background = { Color = colors.active_bg } },
      { Attribute = { Intensity = "Bold" } },
      { Text = " " .. tab_text .. " " },
      { Foreground = { Color = colors.active_bg } },
      { Background = { Color = colors.tab_bar_bg } },
      { Text = RIGHT_PILL },
    }
  else
    return {
      { Foreground = { Color = icon_color } },
      { Background = { Color = colors.tab_bar_bg } },
      { Text = " " .. icon },
      { Foreground = { Color = colors.inactive_fg } },
      { Background = { Color = colors.tab_bar_bg } },
      { Text = " " .. title .. zoom .. " " },
    }
  end
end

local M = {}

function M.setup()
  wezterm.on("format-tab-title", function(tab, _tabs, _panes, _config, _hover, max_width)
    return format_tab(tab, max_width)
  end)
end

return M
