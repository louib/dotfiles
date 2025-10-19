{...}: let
  colors = builtins.fromTOML (builtins.readFile ./colorscheme/colors.toml);

  theme = {
    foreground = "#${colors.nvim.light0}";
    background = "#${colors.nvim.dark0}";
    selection = "#${colors.wezterm.active_tab_bg}";
    cursor = "#${colors.nvim.light1}";
    black = "#${colors.nvim.dark0}";
    red = "#${colors.wezterm.neutral_red}";
    green = "#${colors.wezterm.neutral_green}";
    yellow = "#${colors.wezterm.neutral_yellow}";
    blue = "#${colors.wezterm.neutral_blue}";
    magenta = "#${colors.wezterm.neutral_purple}";
    cyan = "#${colors.wezterm.neutral_aqua}";
    white = "#${colors.nvim.light4}";
    bright_black = "#${colors.wezterm.gray}";
    bright_red = "#${colors.wezterm.bright_red}";
    bright_green = "#${colors.wezterm.bright_green}";
    bright_yellow = "#${colors.nvim.light1}";
    bright_blue = "#${colors.wezterm.bright_blue}";
    bright_magenta = "#${colors.wezterm.bright_purple}";
    bright_cyan = "#${colors.wezterm.bright_aqua}";
    bright_white = "#${colors.nvim.light1}";
  };
in ''
  [editor]
  vim_mode = true

  [theme]
  selection = "${theme.selection}"
  cursor = "${theme.cursor}"
  black = "${theme.black}"
  red = "${theme.red}"
  green = "${theme.green}"
  blue = "${theme.blue}"
  magenta = "${theme.magenta}"
  cyan = "${theme.cyan}"
  white = "${theme.white}"
  bright_black = "${theme.bright_black}"
  bright_red = "${theme.bright_red}"
  bright_green = "${theme.bright_green}"
  bright_blue = "${theme.bright_blue}"
  bright_magenta = "${theme.bright_magenta}"
  bright_cyan = "${theme.bright_cyan}"
  bright_white = "${theme.bright_white}"
''
