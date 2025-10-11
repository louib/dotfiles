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

wezterm.on('gui-startup', function()
  local _, pane, window = wezterm.mux.spawn_window({})
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

-- Load theme from the generated theme file
local theme = require('wezterm_theme')
config.colors = theme.colors
config.window_frame = {
  font = wezterm.font({ family = 'Roboto', weight = 'Bold' }),
  font_size = 10.0,
  active_titlebar_bg = theme.window_frame.active_titlebar_bg,
  inactive_titlebar_bg = theme.window_frame.inactive_titlebar_bg,
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

if wezterm.target_triple:find('darwin') then
  config.default_prog = { '/bin/zsh' }
end

config.check_for_updates = false
config.show_new_tab_button_in_tab_bar = false

config.use_fancy_tab_bar = false

-- Set a generous tab width limit
config.tab_max_width = 40

-- Right-pointing arrow head: 
local RIGHT_POINTING_ARROW = wezterm.nerdfonts.pl_left_hard_divider

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local bg = tab.is_active and theme.colors.tab_bar.active_tab.bg_color or theme.colors.tab_bar.inactive_tab.bg_color
  local fg = tab.is_active and theme.colors.tab_bar.active_tab.fg_color or theme.colors.tab_bar.inactive_tab.fg_color

  -- Determine the title to use. Wezterm's default behavior is to use the
  -- tab title if it's set, otherwise fall back to the pane's title.
  -- We replicate that here.
  local title
  if tab.tab_title and #tab.tab_title > 0 then
    title = tab.tab_title
  else
    title = tab.active_pane.title
  end

  local parts = {}

  -- Left arrow for all tabs except the first, creating a concave effect
  if tab.tab_index > 0 then
    table.insert(parts, { Background = { Color = bg } })
    table.insert(parts, { Foreground = { Color = theme.colors.tab_bar.background } })
    table.insert(parts, { Text = RIGHT_POINTING_ARROW })
  end

  -- The main tab content
  table.insert(parts, { Background = { Color = bg } })
  table.insert(parts, { Foreground = { Color = fg } })
  table.insert(parts, { Text = ' ' .. title .. ' ' })

  -- Right arrow at the end of the tab
  table.insert(parts, { Background = { Color = theme.colors.tab_bar.background } })
  table.insert(parts, { Foreground = { Color = bg } })
  table.insert(parts, { Text = RIGHT_POINTING_ARROW })

  return parts
end)

return config
