local wezterm = require("wezterm")
local nf = wezterm.nerdfonts

-- Nerd Font half-circle glyphs for pill shape
local LEFT_PILL = nf.ple_left_half_circle_thick
local RIGHT_PILL = nf.ple_right_half_circle_thick

-- Colors from color scheme
local scheme = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
local TAB_FG = scheme.background -- base
local TAB_BG = scheme.tab_bar.background -- mantle
local TAB_INACTIVE_FG = scheme.tab_bar.inactive_tab.fg_color

-- Get tab title from CWD: parse github project name or last directory component.
local function get_title_from_cwd(pane)
  local cwd_url = pane.current_working_dir
  if not cwd_url then
    return nil
  end
  local cwd = cwd_url.file_path or tostring(cwd_url)
  local project = cwd:match("/src/github%.com/[^/]+/([^/]+)")
  if project then
    return project
  end
  return cwd:match("([^/]+)/?$")
end

-- Process definitions: icon, color, detection, and title function.
-- Each detect() checks foreground_process_name and pane title.
-- Each get_title() returns the tab label (falls back to default).
-- "default" is used when no other process matches.
local processes = {
  default = {
    icon = nf.dev_terminal,
    color = scheme.brights[1], -- surface2
    get_title = function(pane)
      return get_title_from_cwd(pane) or "~"
    end,
  },
  {
    icon = nf.linux_neovim,
    color = scheme.ansi[3], -- green
    detect = function(name, title)
      return name == "nvim" or name == "vim" or title:find("[Nn]vim") ~= nil
    end,
    get_title = function(pane)
      return get_title_from_cwd(pane) or "nvim"
    end,
  },
  {
    icon = nf.md_docker,
    color = scheme.ansi[5], -- blue
    detect = function(name, title)
      return name == "docker" or title:find("[Dd]ocker") ~= nil
    end,
    get_title = function(pane)
      return get_title_from_cwd(pane) or "docker"
    end,
  },
  {
    icon = nf.md_lan,
    color = scheme.ansi[4], -- yellow
    detect = function(name, title)
      return name == "ssh" or title:find("[Ss][Ss][Hh]") ~= nil
    end,
    get_title = function(pane)
      return get_title_from_cwd(pane) or "ssh"
    end,
  },
  {
    icon = nf.md_robot,
    color = "#D97757", -- claude orange (not in scheme)
    detect = function(name, title)
      return name == "claude" or title:find("[Cc]laude") ~= nil
    end,
    get_title = function(pane)
      return get_title_from_cwd(pane) or "claude"
    end,
  },
}

local function get_process_info(pane)
  local proc = pane.foreground_process_name or ""
  local name = proc:match("([^/\\]+)$") or ""
  local title = pane.title or ""

  for _, p in ipairs(processes) do
    if p.detect(name, title) then
      return p.icon, p.color, p.get_title(pane)
    end
  end

  local d = processes.default
  return d.icon, d.color, d.get_title(pane)
end

local function format_tab(tab, max_width)
  local pane = tab.active_pane
  local icon, icon_color, title = get_process_info(pane)

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
