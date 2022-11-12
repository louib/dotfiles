{
  description = "Static values in my Nix configuration";

  outputs = {self}: {
    lib = {
      # This list is derived from https://github.com/numtide/flake-utils/blob/5aed5285a952e0b949eb3ba02c12fa4fcfef535f/default.nix#L3
      # from which I removed the Darwin systems.
      defaultSystems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      defaultUsername = "louib";
      # TODO should I have my GPG public key here?
      # TODO should I have my SSH public key here?
    };
  };
}
