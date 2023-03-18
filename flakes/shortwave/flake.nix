{
  description = "Shortwave version with the reconnection fix";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    statics = {
      url = "github:louib/dotfiles?dir=flakes/statics";
    };
  };

  outputs = {
    self,
    nixpkgs,
    statics,
    flake-utils,
  }: (
    flake-utils.lib.eachSystem statics.lib.DEFAULT_SYSTEMS (
      system: (
        let
          pkgs = nixpkgs.legacyPackages.${system};
          # TODO use the branch resume_playback_on_failure
          customShortwave = pkgs.shortwave;
        in {
          packages = {
            inherit customShortwave;
          };
        }
      )
    )
  );
}
