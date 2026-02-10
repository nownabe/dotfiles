local wezterm = require("wezterm")
local nf = wezterm.nerdfonts

-- Nerd Font half-circle glyphs for pill shape
local LEFT_PILL = nf.ple_left_half_circle_thick
local RIGHT_PILL = nf.ple_right_half_circle_thick

-- Catppuccin Mocha tab colors
local TAB_FG = "#1e1e2e"          -- base (active tab text)
local TAB_BG = "#181825"          -- mantle (tab bar background)
local TAB_INACTIVE_FG = "#6c7086" -- overlay0 (inactive tab text)

-- Process definitions: icon, color, and detection function.
-- Each detect() checks foreground_process_name and pane title.
-- "default" is used when no other process matches.
local processes = {
  default = {
    icon = nf.dev_terminal,
    color = "#585b70", -- surface2
  },
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

  return processes.default.icon, processes.default.color
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

  local label = title

  -- Truncate if too long (account for pill glyphs + icon)
  local text_max = max_width - 6
  if #label > text_max then
    label = label:sub(1, text_max - 1) .. "…"
  end

  if tab.is_active then
    return {
      { Foreground = { Color = icon_color } },
      { Background = { Color = TAB_BG } },
      { Text = LEFT_PILL },
      { Foreground = { Color = TAB_FG } },
      { Background = { Color = icon_color } },
      { Attribute = { Intensity = "Bold" } },
      { Text = " " .. icon .. " " .. label .. " " },
      { Foreground = { Color = icon_color } },
      { Background = { Color = TAB_BG } },
      { Text = RIGHT_PILL },
    }
  else
    return {
      { Foreground = { Color = icon_color } },
      { Background = { Color = TAB_BG } },
      { Text = "  " .. icon },
      { Foreground = { Color = TAB_INACTIVE_FG } },
      { Background = { Color = TAB_BG } },
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
