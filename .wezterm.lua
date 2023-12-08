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

config.keys = {
  {
    key = 't',
    mods = 'CTRL',
    action = wezterm.action.SpawnTab('DefaultDomain'),
  },
  { key = 'h', mods = 'CTRL', action = wezterm.action.ActivateTabRelative(-1) },
  { key = 'l', mods = 'CTRL', action = wezterm.action.ActivateTabRelative(1) },
}

config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'

config.tab_bar_at_bottom = false

config.window_padding = {
  left = 2,
  right = 2,
  top = 0,
  bottom = 0,
}

wezterm.on('gui-startup', function(_window)
  local _tab, pane, window = wezterm.mux.spawn_window(cmd or {})
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

config.colors = {}

-- and finally, return
--
config.prefer_egl = false
config.front_end = 'Software'

return config
