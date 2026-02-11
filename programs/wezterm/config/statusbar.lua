local wezterm = require("wezterm")
local nf = wezterm.nerdfonts
local scheme = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]

-- Catppuccin Mocha palette
local colors = {
  lavender = scheme.brights[5],
  red = scheme.ansi[2],
  yellow = scheme.ansi[4],
  peach = scheme.indexed and scheme.indexed[209] or "#fab387",
  subtext0 = scheme.brights[1], -- surface2/subtext
  overlay0 = "#6c7086",
  surface0 = "#313244",
  base = scheme.background,
}

-- Mode definitions: key_table name -> display label and color
local modes = {
  copy_mode = { label = " COPY ", color = colors.yellow },
  search_mode = { label = " COPY ", color = colors.yellow },
  resize_pane = { label = "RESIZE", color = colors.red },
}
local default_mode = { label = "NORMAL", color = colors.lavender }

local function left_status(window)
  local workspace = window:active_workspace()
  local key_table = window:active_key_table()
  local mode = modes[key_table] or default_mode

  return wezterm.format({
    { Background = { Color = "none" } },
    { Foreground = { Color = mode.color } },
    { Attribute = { Intensity = "Bold" } },
    { Text = "  " .. mode.label .. "  " },
    { Attribute = { Intensity = "Normal" } },
    { Foreground = { Color = colors.lavender } },
    { Text = workspace .. "  " },
  })
end

local function right_status()
  local cells = {}

  -- Battery
  local battery_info = wezterm.battery_info()
  if battery_info and #battery_info > 0 then
    local charge = battery_info[1].state_of_charge * 100
    table.insert(cells, string.format("%.0f%%", charge))
  end

  -- Hostname
  local hostname = wezterm.hostname()
  hostname = hostname:gsub("%..*$", "") -- strip domain
  table.insert(cells, hostname)

  -- Date/Time
  table.insert(cells, wezterm.strftime("%Y-%m-%d %H:%M:%S"))

  -- Build formatted output
  local elements = {
    { Background = { Color = "none" } },
  }

  for i, cell in ipairs(cells) do
    if i > 1 then
      table.insert(elements, { Foreground = { Color = colors.overlay0 } })
      table.insert(elements, { Text = "  " .. nf.oct_dot_fill .. "  " })
    end
    table.insert(elements, { Foreground = { Color = colors.subtext0 } })
    table.insert(elements, { Text = cell })
  end

  table.insert(elements, { Text = "  " })

  return wezterm.format(elements)
end

local M = {}

function M.setup()
  wezterm.on("update-status", function(window)
    window:set_left_status(left_status(window))
    window:set_right_status(right_status())
  end)
end

return M
