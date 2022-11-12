{
  description = "Flake for KeePassXC development";

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
    flake-utils,
    statics,
  }: (
    flake-utils.lib.eachSystem statics.lib.defaultSystems (
      system: (
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          devShells = {
            default = pkgs.mkShell {
              buildInputs = with pkgs; [
                gnumake
                cmake
                gcc8
                curl
                botan2
                xorg.libXtst
                xorg.libXi
                libargon2
                libusb1
                minizip
                pcsclite
                qrencode
                asciidoctor
                libsForQt5.qt5.qtbase
                libsForQt5.qt5.qttools
                libsForQt5.qt5.qttranslations
                libsForQt5.qt5.qtsvg
                libsForQt5.qt5.qtx11extras
                libsForQt5.qt5.qtwayland
                readline
                zlib
              ];
            };
          };
        }
      )
    )
  );
}
