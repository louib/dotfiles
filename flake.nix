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
  }: (
    flake-utils.lib.eachDefaultSystem (
      system: (
        let
          pkgs = nixpkgs.legacyPackages.${system};

          hostPackages = pkgs.buildEnv {
            name = "";
            paths = with pkgs; [
              # gnome-tweaks
              # gnome-terminal
              # flatpak
              # nmap
              # net-tools
              # bash-completion
              # keepassxc
              # dconf-cli
              # dconf-editor
              # build-essential
              # cryptsetup
              curl
              git
              # git-core
              # pwgen
              # scdaemon
              # thunderbird
              # ttf-bitstream-vera
              # wl-clipboard
            ];
          };
          # TODO add the vim language servers and tools to the host packages.
        in {
          packages = {
            inherit hostPackages;
          };
        }
      )
    )
  );
}
