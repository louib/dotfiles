{
  description = "Configuration for my main systems";

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
    consts = import ./consts.nix;
  in
    (
      flake-utils.lib.eachSystem consts.DEFAULT_SYSTEMS (
        system: (
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in {
            packages = {
            };
          }
        )
      )
    )
    // {inherit consts;};
}
