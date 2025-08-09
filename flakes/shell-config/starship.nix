{colors}: {
  # Get editor completions based on the config schema
  "$schema" = "https://starship.rs/config-schema.json";

  format = "$username$hostname$time$directory$git_branch$git_state$git_status$nix_shell$character";

  # Disable the blank line at the start of the prompt
  add_newline = false;

  username = {
    show_always = true;
    style_user = "bold fg:#${colors.default-fg} bg:#${colors.user-bg}";
    style_root = "bold fg:#${colors.default-fg} bg:#${colors.root-user-bg}";
    format = "[ $user ]($style)";
  };

  hostname = {
    ssh_only = true;
    format = "[ $hostname ]($style)";
    style = "bold fg:#${colors.default-fg} bg:#${colors.hostname-bg}";
  };

  time = {
    disabled = false;
    time_format = "%X";
    style = "bold fg:#${colors.default-fg} bg:#${colors.time-bg}";
    format = "[ $time ]($style)";
  };

  directory = {
    format = "[ $path ]($style)";
    style = "bold fg:#${colors.default-fg} bg:#${colors.directory-bg}";
    truncation_length = 3;
    truncation_symbol = "…/";
  };

  git_branch = {
    format = "[( $branch)]($style)";
    style = "bold fg:#${colors.default-fg} bg:#${colors.git-branch-bg}";
    symbol = "";
  };

  git_state = {
    format = "[( $state)]($style)";
    style = "bold fg:#${colors.default-fg} bg:#${colors.git-state-bg}";
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
    style = "bold fg:#${colors.default-fg} bg:#${colors.git-status-bg}";
    up_to_date = "✓";
  };

  nix_shell = {
    style = "bold fg:#${colors.nix-prompt-fg} bg:#${colors.nix-prompt-bg}";
    symbol = "nix";
    format = "[ $symbol ]($style)";
  };

  character = {
    success_symbol = "[ ](bold fg:#${colors.success-symbol-fg} bg:#${colors.success-symbol-bg})";
    error_symbol = "[ ](bold fg:#${colors.default-fg} bg:#${colors.error-symbol-bg})";
    # FIXME vicmd_symbol is not supported on bash :(
    # https://starship.rs/config/#character
    # vicmd_symbol = "[ ](bg:green)";
  };
}
