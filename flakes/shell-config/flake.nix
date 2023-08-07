{
  description = "Collection of functions that define my shell (bash/zsh) configuration";

  outputs = {self}: {
    lib = rec {
      # The top-level environment variables that should be defined in my shell.
      VARIABLES = {
        VISUAL = "nvim";
        EDITOR = "nvim";
      };
      READLINE_CONFIG = builtins.readFile (./. + "/.inputrc");
      SHELL_CONFIG = builtins.readFile (./. + "/shell-init.sh");
      BASH_CONFIG = (builtins.readFile (./. + "/bashrc.sh")) + SHELL_CONFIG;
      ZSH_CONFIG = (builtins.readFile (./. + "/zshrc.sh")) + SHELL_CONFIG;
      STARSHIP_CONFIG = builtins.fromTOML (builtins.readFile (./. + "/starship.toml"));
      SHELL_ALIASES = [
        # Defaults from template .bashrc config
        {
          name = "ll";
          target = "ls -alF";
        }
        {
          name = "la";
          target = "ls -A";
        }
        # Cargo stuff
        {
          name = "ci";
          target = "cargo install --force --path .";
        }
        {
          name = "cb";
          target = "cargo build";
        }
        {
          name = "ct";
          target = "cargo test";
        }
        {
          name = "cf";
          target = "find . -name '*.rs' -exec rustfmt {} \;";
        }
        # Nix stuff
        {
          name = "nix-search";
          target = "nix-env -qa";
        }
        {
          name = "ndv";
          target = "nix develop .";
        }
        {
          name = "nfc";
          target = "nix flake check";
        }
      ];
      SHELL_ALIASES_TUPLES = builtins.map (alias: [alias.name alias.target]) SHELL_ALIASES;
      SHELL_ALIASES_STRING = builtins.map (alias: "alias ${alias.name}=${alias.target}") SHELL_ALIASES;

      # Full documentation on the syntax for the LS_COLORS variable can be found here
      # https://linuxopsys.com/topics/colors-for-ls-mean-change-colors-for-ls-in-bash
      LS_COLORS = builtins.foldl' (x: y: y + ":" + x) "" [
        "no=0;35;0"
        "fi=0;35;0"
        "di=01;34"
        "ln=01;36"
        "mh=00"
        "pi=40;33"
        "so=01;35"
        "do=01;35"
        "bd=40;33;01"
        "cd=40;33;01"
        "or=40;31;01"
        "mi=00"
        "su=37;41"
        "sg=30;43"
        "ca=00"
        "tw=30;42"
        "ow=34;42"
        "st=37;44"
        "ex=01;32"

        # Archive formats
        "*.tar=01;31"
        "*.tgz=01;31"
        "*.arc=01;31"
        "*.arj=01;31"
        "*.taz=01;31"
        "*.lha=01;31"
        "*.lz4=01;31"
        "*.lzh=01;31"
        "*.lzma=01;31"
        "*.tlz=01;31"
        "*.txz=01;31"
        "*.tzo=01;31"
        "*.t7z=01;31"
        "*.zip=01;31"
        "*.z=01;31"
        "*.dz=01;31"
        "*.gz=01;31"
        "*.lrz=01;31"
        "*.lz=01;31"
        "*.lzo=01;31"
        "*.xz=01;31"
        "*.zst=01;31"
        "*.tzst=01;31"
        "*.bz2=01;31"
        "*.bz=01;31"
        "*.tbz=01;31"
        "*.tbz2=01;31"
        "*.tz=01;31"
        "*.deb=01;31"
        "*.rpm=01;31"
        "*.jar=01;31"
        "*.war=01;31"
        "*.ear=01;31"
        "*.sar=01;31"
        "*.rar=01;31"
        "*.alz=01;31"
        "*.ace=01;31"
        "*.zoo=01;31"
        "*.cpio=01;31"
        "*.7z=01;31"
        "*.rz=01;31"

        # Data formats
        "*.kdbx=01;35"
        "*.json=01;35"
        "*.toml=01;35"
        "*.yaml=01;35"
        "*.yml=01;35"

        # Markdown files and documentation
        "*.md=00;36"
        "*LICENSE*=00;36"
        "*COPYING=00;36"

        # lock files
        "*Cargo.lock=00;31"
        "*package-lock.json=00;31"
        "*yarn.lock=00;31"
        "*flake.lock=00;31"

        # manifest files
        "*Cargo.toml=00;31"
        "*package.json=00;31"

        # build files
        "*Dockerfile*=00;31"
        "*Makefile=00;31"
        "*CMakeLists.txt=00;31"

        # code
        "*.nix=00;33"
        "*.sh=00;33"
        "*.cpp=00;33"
        "*.rs=00;33"
        "*.lua=00;33"
        "*.c=00;33"
        "*.py=00;33"
        "*.ts=00;33"

        "*.cab=01;31"
        "*.wim=01;31"
        "*.swm=01;31"
        "*.dwm=01;31"
        "*.esd=01;31"
        "*.avif=01;35"
        "*.jpg=01;35"
        "*.jpeg=01;35"
        "*.mjpg=01;35"
        "*.mjpeg=01;35"
        "*.gif=01;35"
        "*.bmp=01;35"
        "*.pbm=01;35"
        "*.pgm=01;35"
        "*.ppm=01;35"
        "*.tga=01;35"
        "*.xbm=01;35"
        "*.xpm=01;35"
        "*.tif=01;35"
        "*.tiff=01;35"
        "*.png=01;35"
        "*.svg=01;35"
        "*.svgz=01;35"
        "*.mng=01;35"
        "*.pcx=01;35"
        "*.mov=01;35"
        "*.mpg=01;35"
        "*.mpeg=01;35"
        "*.m2v=01;35"
        "*.mkv=01;35"
        "*.webm=01;35"
        "*.webp=01;35"
        "*.ogm=01;35"
        "*.mp4=01;35"
        "*.m4v=01;35"
        "*.mp4v=01;35"
        "*.vob=01;35"
        "*.qt=01;35"
        "*.nuv=01;35"
        "*.wmv=01;35"
        "*.asf=01;35"
        "*.rm=01;35"
        "*.rmvb=01;35"
        "*.flc=01;35"
        "*.avi=01;35"
        "*.fli=01;35"
        "*.flv=01;35"
        "*.gl=01;35"
        "*.dl=01;35"
        "*.xcf=01;35"
        "*.xwd=01;35"
        "*.yuv=01;35"
        "*.cgm=01;35"
        "*.emf=01;35"
        "*.ogv=01;35"
        "*.ogx=01;35"
        "*.aac=00;36"
        "*.au=00;36"
        "*.flac=00;36"
        "*.m4a=00;36"
        "*.mid=00;36"
        "*.midi=00;36"
        "*.mka=00;36"
        "*.mp3=00;36"
        "*.mpc=00;36"
        "*.ogg=00;36"
        "*.ra=00;36"
        "*.wav=00;36"
        "*.oga=00;36"
        "*.opus=00;36"
        "*.spx=00;36"
        "*.xspf=00;36"
        "*~=00;90"
        "*#=00;90"
        "*.bak=00;90"
        "*.old=00;90"
        "*.orig=00;90"
        "*.part=00;90"
        "*.rej=00;90"
        "*.swp=00;90"
        "*.tmp=00;90"
        "*.dpkg-dist=00;90"
        "*.dpkg-old=00;90"
        "*.ucf-dist=00;90"
        "*.ucf-new=00;90"
        "*.ucf-old=00;90"
        "*.rpmnew=00;90"
        "*.rpmorig=00;90"
        "*.rpmsave=00;90"
      ];
      LS_COLORS_CONFIG = "export LS_COLORS=\"${LS_COLORS}\"";
    };
  };
}
