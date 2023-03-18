{
  description = "Shortwave version with the reconnection fix";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }: let
    consts = import ./../../consts.nix;
  in (
    flake-utils.lib.eachSystem consts.DEFAULT_SYSTEMS (
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
