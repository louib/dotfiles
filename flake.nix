{
  description = "Configuration for my main systems";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs";
    };
    statics = {
      url = "github:louib/dotfiles?dir=flakes/statics";
    };
    neovim = {
      url = "github:louib/dotfiles?dir=flakes/nvim";
      inputs.flake-utils.follows = "flake-utils";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = {
    self,
    nixpkgs,
    statics,
    neovim,
    flake-utils,
  }: (
    flake-utils.lib.eachSystem statics.lib.defaultSystems (
      system: (
        let
          pkgs = nixpkgs.legacyPackages.${system};
          neovimPackages = neovim.packages.${system};

          # Other packages that I want to be available, but I don't necessarily use day to day.
          miscPackages = with pkgs; {
            inherit gnome-clocks;
          };

          hostPackages = pkgs.buildEnv {
            name = "";
            # TODO add neovim packages.
            paths = with pkgs; [
              evince
              # gnome-tweaks
              # gnome-terminal
              # flatpak
              # nmap
              # net-tools
              bash-completion
              # keepassxc
              # dconf-cli
              zotero
              # dconf-editor
              # build-essential
              # cryptsetup
              curl
              git
              # git-core
              pwgen
              # scdaemon
              thunderbird
              # ttf-bitstream-vera
              # wl-clipboard
            ];
          };
          # TODO add the vim language servers and tools to the host packages.
        in {
          packages =
            {
              inherit hostPackages;
            }
            // neovimPackages;
        }
      )
    )
  );
}
