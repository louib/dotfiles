{
  description = "Emoji on the command line 😱";

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
  }: (
    flake-utils.lib.eachDefaultSystem (
      system: (
        let
          pkgs = nixpkgs.legacyPackages.${system};
          version = "2.2.0";
        in {
          packages.default = pkgs.stdenv.mkDerivation rec {
            name = "emojify";
            inherit version;
            src = builtins.fetchTarball {
              url = "https://github.com/mrowa44/emojify/archive/refs/tags/${version}.tar.gz";
              sha256 = "15d0gzhjypc7rykpl5wxqly9iw7b9xw2fqnc397rra0kri5pxig9";
            };

            installPhase = ''
              mkdir -p $out/bin
              cp ${src}/emojify $out/bin/emojify
              chmod +x $out/bin/emojify
            '';
          };
        }
      )
    )
  );
}
