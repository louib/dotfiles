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
              paths = with pkgs; [
                gnome.gnome-tweaks
                gnome.geary
                # gnome-feeds
                # kmail if geary does not work
                # nerdfonts is not installed as a dependency of startship, because
                # only some themes use it. I stopped using the fonts for the moment
                # because I was not able to install them with Nix on Ubuntu.
                # nerdfonts
                zotero
                # dconf-cli
                # dconf-editor
                # build-essential
                curl
                pwgen
                # epiphany
                megapixels
                # ttf-bitstream-vera
                # wl-clipboard
              ];
            };
          in {
            packages = {
              inherit hostPackages;
            };
          }
        )
      )
    )
    // {inherit consts;};
}
