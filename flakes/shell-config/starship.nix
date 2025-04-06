{colors}: {
  # Get editor completions based on the config schema
  "$schema" = "https://starship.rs/config-schema.json";

  format = ''
    $username\\
    $hostname\\
    $time\\
    $directory\\
    $git_branch\\
    $git_state\\
    $git_status\\
    $nix_shell\\
    $character
  '';

  # Disable the blank line at the start of the prompt
  add_newline = false;

  username = {
    show_always = true;
    style_user = "bold fg:#${colors.default-fg} bg:#cc241d";
    style_root = "bold fg:#${colors.default-fg} bg:#fb4934";
    format = "[ $user ]($style)";
  };

  hostname = {
    ssh_only = true;
    format = "[ $hostname ]($style)";
    style = "bold fg:#${colors.default-fg} bg:#d65d0e";
  };

  time = {
    disabled = false;
    time_format = "%X";
    style = "bold fg:#${colors.default-fg} bg:#b16286";
    format = "[ $time ]($style)";
  };

  directory = {
    format = "[ $path ]($style)";
    style = "bold fg:#${colors.default-fg} bg:#458588";
    truncation_length = 3;
    truncation_symbol = "…/";
  };

  git_branch = {
    format = "[( $branch)]($style)";
    style = "bold fg:#${colors.default-fg} bg:#689d6a";
    symbol = "";
  };

  git_state = {
    format = "[( $state)]($style)";
    style = "bold fg:#${colors.default-fg} bg:#689d6a";
  };

  git_status = {
    format = "[( $all_status$ahead_behind) ]($style)";
    ahead = ">";
    behind = "<";
    deleted = "-";
    diverged = "<>";
    modified = "*";
    renamed = "r";
    staged = "+";
    conflicted = "!";
    stashed = "";
    style = "bold fg:#${colors.default-fg} bg:#689d6a";
    up_to_date = "✓";
  };

  nix_shell = {
    style = "bold fg:#282828 bg:#8ec07c";
    symbol = "nix";
    format = "[ $symbol ]($style)";
  };

  character = {
    success_symbol = "[ ](bold fg:#282828 bg:#98971a)";
    error_symbol = "[ ](bold fg:#${colors.default-fg} bg:#cc241d)";
    # FIXME vicmd_symbol is not supported on bash :(
    # https://starship.rs/config/#character
    # vicmd_symbol = "[ ](bg:green)";
  };
}
