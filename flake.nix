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

          hostPackages = pkgs.buildEnv {
            name = "";
            # TODO add neovim packages.
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
