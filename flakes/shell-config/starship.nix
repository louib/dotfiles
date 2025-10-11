{colors}: {
  # Get editor completions based on the config schema
  "$schema" = "https://starship.rs/config-schema.json";

  format = ''$username$hostname$time$directory$git_branch$git_state$git_status$nix_shell $character'';

  # Disable the blank line at the start of the prompt
  add_newline = false;

  username = {
    show_always = true;
    style_user = "bold fg:#${colors.starship.default-fg} bg:#${colors.starship.user-bg}";
    style_root = "bold fg:#${colors.starship.default-fg} bg:#${colors.starship.root-user-bg}";
    format = "[ $user ]($style)[](fg:#${colors.starship.user-bg})";
  };

  hostname = {
    ssh_only = true;
    style = "bold fg:#${colors.starship.default-fg} bg:#${colors.starship.hostname-bg}";
    format = "[](fg:#282828 bg:#${colors.starship.hostname-bg})[ $hostname ]($style)[](fg:#${colors.starship.hostname-bg})";
  };

  time = {
    disabled = false;
    time_format = "%X";
    style = "bold fg:#${colors.starship.default-fg} bg:#${colors.starship.time-bg}";
    format = "[](fg:#282828 bg:#${colors.starship.time-bg})[ $time ]($style)[](fg:#${colors.starship.time-bg})";
  };

  directory = {
    style = "bold fg:#${colors.starship.default-fg} bg:#${colors.starship.directory-bg}";
    format = "[](fg:#282828 bg:#${colors.starship.directory-bg})[ $path ]($style)[](fg:#${colors.starship.directory-bg})";
    truncation_length = 3;
    truncation_symbol = "…/";
  };

  git_branch = {
    symbol = "";
    style = "bold fg:#${colors.starship.default-fg} bg:#${colors.starship.git-branch-bg}";
    format = "[](fg:#282828 bg:#${colors.starship.git-branch-bg})[ $branch ]($style)";
  };

  git_state = {
    style = "bold fg:#${colors.starship.default-fg} bg:#${colors.starship.git-state-bg}";
    format = "[$state]($style)";
  };

  git_status = {
    style = "bold fg:#${colors.starship.default-fg} bg:#${colors.starship.git-status-bg}";
    format = "[ $all_status$ahead_behind ]($style)[](fg:#${colors.starship.git-status-bg})";
    ahead = ">";
    behind = "<";
    deleted = "-";
    diverged = "<>";
    modified = "*";
    renamed = "r";
    staged = "+";
    conflicted = "!";
    stashed = "";
    up_to_date = "✓";
  };

  nix_shell = {
    symbol = "nix";
    style = "bold fg:#${colors.starship.nix-prompt-fg} bg:#${colors.starship.nix-prompt-bg}";
    format = "[](fg:#282828 bg:#${colors.starship.nix-prompt-bg})[ $symbol ]($style)[](fg:#${colors.starship.nix-prompt-bg})";
  };

  character = {
    success_symbol = "[❯](bold fg:#${colors.starship.success-symbol-bg})";
    error_symbol = "[❯](bold fg:#${colors.starship.error-symbol-bg})";
    # FIXME vicmd_symbol is not supported on bash :(
    # https://starship.rs/config/#character
    # vicmd_symbol = "[ ](bg:green)";
  };
}
