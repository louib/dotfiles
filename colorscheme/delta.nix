{...}: let
  colors = builtins.fromTOML (builtins.readFile ./colors.toml);
in {
  enable = true;
  options = {
    features = "my-custom-theme";
    side-by-side = true;
    line-numbers = true;

    my-custom-theme = {
      dark = true;
      syntax-theme = "gruvbox-dark";

      # File and hunk headers
      file-style = "bold #${colors.directory-bg}";
      file-decoration-style = "bold #${colors.directory-bg} ul";
      hunk-header-style = "bold #${colors.directory-bg}";
      hunk-header-decoration-style = "bold #${colors.directory-bg} box";

      # Added lines
      plus-style = "#${colors.delta-plus-fg} #${colors.delta-plus-bg}";
      plus-emph-style = "bold #${colors.delta-plus-fg} #${colors.delta-plus-bg}";
      plus-non-emph-style = "#${colors.delta-plus-non-emph-fg} #${colors.delta-plus-bg}";

      # Removed lines
      minus-style = "#${colors.delta-minus-fg} #${colors.delta-minus-bg}";
      minus-emph-style = "bold #${colors.delta-minus-fg} #${colors.delta-minus-bg}";
      minus-non-emph-style = "#${colors.delta-minus-non-emph-fg} #${colors.delta-minus-bg}";

      # Unchanged lines
      zero-style = "syntax #${colors.default-fg}";

      # Other elements
      commit-style = "bold #${colors.hostname-bg}";
      commit-decoration-style = "bold #${colors.hostname-bg} ul";
      line-numbers-left-style = "#${colors.git-status-bg}";
      line-numbers-right-style = "#${colors.git-status-bg}";
      line-numbers-minus-style = "#${colors.error-symbol-bg}";
      line-numbers-plus-style = "#${colors.success-symbol-bg}";
    };
  };
}
