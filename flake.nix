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
      inputs.nixpkgs.follows = "nixpkgs";
    };
    keepassxc = {
      url = "github:louib/dotfiles?dir=flakes/keepassxc";
      inputs.flake-utils.follows = "flake-utils";
      inputs.statics.follows = "statics";
      # I do active development on this one, so I might be tempted to freeze the
      # nixpkgs version?
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    emojify = {
      url = "github:louib/dotfiles?dir=flakes/emojify";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kp2vcard = {
      url = "github:louib/kp2vcard";
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
    emojify,
    keepassxc,
    kp2vcard,
    flake-utils,
  }: (
    flake-utils.lib.eachSystem statics.lib.defaultSystems (
      system: (
        let
          pkgs = nixpkgs.legacyPackages.${system};
          neovimPackages = neovim.packages.${system};
          emojifyPackages = emojify.packages.${system};
          keepassxcPackages = keepassxc.packages.${system};
          kp2vcardPackages = kp2vcard.packages.${system};

          # Other packages that I want to be available, but I don't necessarily use day to day.
          miscPackages = with pkgs; {
            inherit gnome-clocks;
            inherit fractal;
            inherit vlc;
            inherit phosh;
            inherit phoc;
            # flatpak
            # flatpak-builder
            # age (as a future replacement of pgp)
          };

          containerPackages = with pkgs; {
            # inherit runc;
            # inherit podman;
            # inherit conmon;
          };

          devPackages = with pkgs; {
            inherit nmap;
            inherit net-tools;
            # binutils (https://sourceware.org/git/binutils-gdb.git)
            # coreutils (https://github.com/coreutils/coreutils.git)
            # bison (https://git.savannah.gnu.org/git/bison.git)
            # autoconf/autotools (https://git.sv.gnu.org/r/autoconf.git)
            # automake (https://git.savannah.gnu.org/cgit/automake.git)
            # bash (https://git.savannah.gnu.org/git/bash.git)
            # bc (https://git.yzena.com/gavin/bc.git)
            # bzip (https://sourceware.org/git/bzip2.git)
            # check (https://github.com/libcheck/check.git)
            # dejagnu (https://git.savannah.gnu.org/git/dejagnu.git)
            # diffutils (https://git.savannah.gnu.org/git/diffutils.git)
            # e2fs (https://git.kernel.org/pub/scm/fs/ext2/e2fsprogs.git)
            # TODO add other filesystems!!
            # elfutils (https://sourceware.org/git/elfutils.git)
            # patchelf (https://github.com/NixOS/patchelf.git)
            # eudev (https://anongit.gentoo.org/git/proj/eudev.git)
            # libexpat (https://github.com/libexpat/libexpat.git)
            # file (https://github.com/file/file.git)
            # glibc
            # acl (https://git.savannah.nongnu.org/git/acl.git)
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
            # cargo
            # rustc
            # lua
          };

          hostPackages = pkgs.buildEnv {
            name = "";
            # TODO add neovim packages.
            # TODO add keepassxc
            # TODO add gpg
            paths = with pkgs; [
              evince
              gnome.gnome-tweaks
              # gnome-disks
              gnome.gnome-terminal
              gnome.geary
              # gnome-feeds
              # kmail if geary does not work
              bash-completion
              # FIXME maybe starship should go into the shell-config?
              starship
              # nerdfonts is not installed as a dependency of startship, because
              # only some themes use it. I stopped using the fonts for the moment
              # because I was not able to install them with Nix on Ubuntu.
              # nerdfonts
              # keepassxc
              zotero
              zola
              # dconf-cli
              # dconf-editor
              # build-essential
              # cryptsetup
              curl
              git
              pwgen
              # scdaemon
              thunderbird
              firefox
              # epiphany
              chatty
              megapixels
              ttf-bitstream-vera
              # wl-clipboard
            ];
          };
          # TODO add the vim language servers and tools to the host packages.
        in {
          packages =
            {
              inherit hostPackages;
            }
            // neovimPackages
            // keepassxcPackages
            // kp2vcardPackages
            // emojifyPackages;
        }
      )
    )
  );
}
