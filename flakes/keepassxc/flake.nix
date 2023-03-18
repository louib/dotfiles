{
  description = "Flake for KeePassXC development";

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
        in {
          packages = {
            keepassxc = pkgs.keepassxc;
          };
          devShells = {
            default = pkgs.mkShell {
              shellHook = ''
                export QT_LOGGING_RULES="*.debug=false"
              '';
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
