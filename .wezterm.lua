-- Pull in the wezterm API
local wezterm = require('wezterm')

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = 'AdventureTime'
-- config.color_scheme = 'Bespin (base16)'
-- config.color_scheme = 'Black Metal (base16)'
-- config.color_scheme = 'Brush Trees Dark (base16)'
-- config.color_scheme = 'Zenburn'

local function url_decode(s)
  s = string.gsub(s, '%%(%x%x)', function(h)
    return string.char(tonumber(h, 16))
  end)
  return s
end

wezterm.on('newtab-cwd', function(window, pane)
  local cwd = url_decode(pane:get_current_working_dir())
  -- wezterm.log_info(pane:get_current_working_dir())
  -- wezterm.log_info(cwd)
  window:perform_action(
    wezterm.action({ SpawnCommandInNewTab = {
      args = { 'cmd', '/k', 'cd /d ' .. cwd },
    } }),
    pane
  )
end)

config.leader = { key = 'Escape', mods = 'ALT', timeout_milliseconds = 1000 }
config.keys = {
  -- Tabs shortcuts
  {
    key = 't',
    mods = 'CTRL',
    action = wezterm.action.SpawnTab('DefaultDomain'),
  },
  { key = 'h', mods = 'CTRL', action = wezterm.action.ActivateTabRelative(-1) },
  { key = 'l', mods = 'CTRL', action = wezterm.action.ActivateTabRelative(1) },

  -- Pane shortcuts
  { key = 'n', mods = 'CTRL|SHIFT', action = wezterm.action.SplitVertical({ domain = 'CurrentPaneDomain' }) },
  {
    key = 'j',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ActivatePaneDirection('Down'),
  },
  {
    key = 'k',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ActivatePaneDirection('Up'),
  },
}

config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'

config.tab_bar_at_bottom = false
config.tab_max_width = 20

config.window_padding = {
  left = 2,
  right = 2,
  top = 0,
  bottom = 0,
}

wezterm.on('gui-startup', function(_window)
  local _tab, pane, window = wezterm.mux.spawn_window({})
  local gui_window = window:gui_window()
  gui_window:perform_action(wezterm.action.ToggleFullScreen, pane)
end)

for i = 1, 8 do
  -- CTRL+ALT + number to activate that tab
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'ALT',
    action = wezterm.action.ActivateTab(i - 1),
  })
end

-- See https://user-images.githubusercontent.com/58662350/214389078-702babc1-fd73-40d7-9fb2-ac2eeaedeeea.png
-- for the colors used by sonokai
config.colors = {
  background = '#2C2E34',

  -- The default text color
  foreground = 'white',

  -- cursor_bg = '#52ad70',
  cursor_fg = 'white',
}

config.use_fancy_tab_bar = false
config.hide_mouse_cursor_when_typing = false

config.prefer_egl = true

return config
