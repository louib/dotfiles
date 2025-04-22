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

  { key = 'f', mods = 'CTRL|SHIFT', action = wezterm.action.ToggleFullScreen },
}

config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'

config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

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

-- Using Gruvbox colors for better readability and accessibility
config.colors = {
  -- Background with slight transparency for better contrast
  background = '#282828',

  -- Soft white foreground that's easy on the eyes
  foreground = '#ebdbb2',

  -- Cursor colors
  cursor_bg = '#d5c4a1',
  cursor_fg = '#282828',

  -- Selection colors
  selection_bg = '#504945',
  selection_fg = '#ebdbb2',

  -- Normal colors (for better distinction)
  ansi = {
    '#282828', -- black
    '#cc241d', -- red
    '#98971a', -- green
    '#d79921', -- yellow
    '#458588', -- blue
    '#b16286', -- magenta
    '#689d6a', -- cyan
    '#a89984', -- white
  },

  -- Bright colors (for emphasis)
  brights = {
    '#928374', -- bright black
    '#fb4934', -- bright red
    '#b8bb26', -- bright green
    '#fabd2f', -- bright yellow
    '#83a598', -- bright blue
    '#d3869b', -- bright magenta
    '#8ec07c', -- bright cyan
    '#ebdbb2', -- bright white
  },
}

config.tab_bar_at_bottom = false
config.tab_max_width = 35
config.show_tab_index_in_tab_bar = false
config.use_fancy_tab_bar = false
config.hide_mouse_cursor_when_typing = false

-- Tab bar styling
config.window_frame = {
  font = wezterm.font({ family = 'Roboto', weight = 'Bold' }),
  font_size = 10.0,
  active_titlebar_bg = '#282828',
  inactive_titlebar_bg = '#1d2021',
}

config.colors.tab_bar = {
  background = '#282828',
  active_tab = {
    bg_color = '#458588',
    fg_color = '#ebdbb2',
    intensity = 'Bold',
  },
  inactive_tab = {
    bg_color = '#3c3836',
    fg_color = '#a89984',
  },
  new_tab = {
    bg_color = '#3c3836',
    fg_color = '#bdae93',
  },
  new_tab_hover = {
    bg_color = '#458588',
    fg_color = '#ebdbb2',
  },
}

-- Add padding around the tab bar
config.window_padding = {
  left = 2,
  right = 2,
  top = 2,
  bottom = 2,
}

config.enable_kitty_keyboard = true

local function bash_exists()
  local file = io.open('/bin/bash', 'r')
  if file then
    file:close()
    return true
  else
    return false
  end
end

if bash_exists() then
  -- This is required to circumvent the following bug:
  -- https://github.com/wez/wezterm/issues/2870
  config.default_prog = { '/bin/bash' }
end

config.prefer_egl = true

if os.getenv('WEZTERM_DEFAULT_TO_ZSH') == 'true' then
  config.default_prog = { '/bin/zsh' }
end

return config
