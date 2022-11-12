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
    flake-utils.lib.eachSystem statics.lib.defaultSystems (
      system: (
        let
          pkgs = nixpkgs.legacyPackages.${system};
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
