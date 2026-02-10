local wezterm = require("wezterm")
local nf = wezterm.nerdfonts

-- Catppuccin Mocha palette
local colors = {
  active_bg = "#89b4fa",  -- blue
  active_fg = "#1e1e2e",  -- base
  inactive_fg = "#6c7086", -- overlay0
  tab_bar_bg = "#181825", -- mantle
}

-- Nerd Font half-circle glyphs for pill shape
local LEFT_PILL = nf.ple_left_half_circle_thick
local RIGHT_PILL = nf.ple_right_half_circle_thick

-- Process definitions: icon, color, and detection function.
-- Each detect(pane) checks foreground_process_name and pane title.
local processes = {
  {
    icon = nf.linux_neovim,
    color = "#a6e3a1", -- green
    detect = function(name, title)
      return name == "nvim" or name == "vim" or title:find("[Nn]vim") ~= nil
    end,
  },
  {
    icon = nf.md_docker,
    color = "#89b4fa", -- blue
    detect = function(name, title)
      return name == "docker" or title:find("[Dd]ocker") ~= nil
    end,
  },
  {
    icon = nf.md_lan,
    color = "#f9e2af", -- yellow
    detect = function(name, title)
      return name == "ssh" or title:find("[Ss][Ss][Hh]") ~= nil
    end,
  },
  {
    icon = nf.md_robot,
    color = "#D97757", -- claude orange
    detect = function(name, title)
      return name == "claude" or title:find("[Cc]laude") ~= nil
    end,
  },
}

local function get_process_info(pane)
  local proc = pane.foreground_process_name or ""
  local name = proc:match("([^/\\]+)$") or ""
  local title = pane.title or ""

  for _, p in ipairs(processes) do
    if p.detect(name, title) then
      return p.icon, p.color
    end
  end

  return nf.dev_terminal, "#585b70" -- surface2
end

local function get_project_name(cwd_url)
  if not cwd_url then
    return nil
  end

  -- current_working_dir is a Url object; use file_path field
  local cwd = cwd_url.file_path or tostring(cwd_url)
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

  local label = title .. zoom

  -- Truncate if too long (account for pill glyphs + icon)
  local text_max = max_width - 6
  if #label > text_max then
    label = label:sub(1, text_max - 1) .. "…"
  end

  if tab.is_active then
    return {
      { Foreground = { Color = icon_color } },
      { Background = { Color = colors.tab_bar_bg } },
      { Text = LEFT_PILL },
      { Foreground = { Color = colors.active_fg } },
      { Background = { Color = icon_color } },
      { Attribute = { Intensity = "Bold" } },
      { Text = " " .. icon .. " " .. label .. " " },
      { Foreground = { Color = icon_color } },
      { Background = { Color = colors.tab_bar_bg } },
      { Text = RIGHT_PILL },
    }
  else
    return {
      { Foreground = { Color = icon_color } },
      { Background = { Color = colors.tab_bar_bg } },
      { Text = "  " .. icon },
      { Foreground = { Color = colors.inactive_fg } },
      { Background = { Color = colors.tab_bar_bg } },
      { Text = " " .. label .. "  " },
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
