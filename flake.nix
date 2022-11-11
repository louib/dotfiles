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
    emojify = {
      url = "github:louib/dotfiles?dir=flakes/emojify";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
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
    emojify,
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
            inherit vlc;
            inherit phosh;
            inherit phoc;
            # flatpak
            # flatpak-builder
          };

          containerPackages = with pkgs; {
            # inherit runc;
            # inherit podman;
            # inherit conmon;
          };

          devPackages = with pkgs; {
            inherit nmap;
            inherit net-tools;
            # bison
            # cmake
            # ninja
            # meson
            # attr
            # gettext
            # autopoint ??
            # dbus
            # iptables
            # libtool
            # btrfs-progs
            # pkg-config
          };

          hostPackages = pkgs.buildEnv {
            name = "";
            # TODO add neovim packages.
            paths = with pkgs; [
              evince
              # gnome-tweaks
              gnome.gnome-terminal
              bash-completion
              # keepassxc
              zotero
              # dconf-cli
              # dconf-editor
              # build-essential
              # cryptsetup
              curl
              git
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
