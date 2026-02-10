local wezterm = require("wezterm")
local nf = wezterm.nerdfonts

-- Catppuccin Mocha palette
local colors = {
  active_bg = "#89b4fa", -- blue
  active_fg = "#1e1e2e", -- base
  inactive_fg = "#6c7086", -- overlay0
  tab_bar_bg = "#181825", -- mantle
}

-- Nerd Font half-circle glyphs for pill shape
local LEFT_PILL = nf.ple_left_half_circle_thick
local RIGHT_PILL = nf.ple_right_half_circle_thick

-- Process name -> { icon, color }
local process_icons = {
  nvim = { icon = nf.linux_neovim, color = "#a6e3a1" }, -- green
  vim = { icon = nf.linux_neovim, color = "#a6e3a1" },
  docker = { icon = nf.md_docker, color = "#89b4fa" }, -- blue
  ssh = { icon = nf.md_lan, color = "#f9e2af" }, -- yellow
  claude = { icon = nf.md_robot, color = "#cba6f7" }, -- mauve
  node = { icon = nf.dev_nodejs_small, color = "#a6e3a1" },
  python = { icon = nf.dev_python, color = "#f9e2af" },
  ruby = { icon = nf.dev_ruby, color = "#f38ba8" }, -- red
  go = { icon = nf.dev_go, color = "#89dceb" }, -- teal
  cargo = { icon = nf.dev_rust, color = "#fab387" }, -- peach
  rust = { icon = nf.dev_rust, color = "#fab387" },
}

local function get_process_info(pane)
  local process_name = pane.foreground_process_name:match("([^/\\]+)$") or ""
  local info = process_icons[process_name]
  if info then
    return info.icon, info.color
  end
  return nf.dev_terminal, colors.active_bg
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
      zoom = " " .. nf.md_magnify
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
