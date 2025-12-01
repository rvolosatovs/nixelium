{
  self,
  base16-shell,
  nixify,
  nixlib,
  nixpkgs-darwin,
  nixpkgs-nixos,
  nixpkgs-unstable,
  ...
}: {
  config,
  osConfig ? null,
  pkgs,
  ...
}:
with nixlib.lib; let
  headphones = "70:26:05:CF:7F:C2";

  schemes.tomorrow-night.base00 = "1d1f21";
  schemes.tomorrow-night.base01 = "282a2e";
  schemes.tomorrow-night.base02 = "373b41";
  schemes.tomorrow-night.base03 = "969896";
  schemes.tomorrow-night.base04 = "b4b7b4";
  schemes.tomorrow-night.base05 = "c5c8c6";
  schemes.tomorrow-night.base06 = "e0e0e0";
  schemes.tomorrow-night.base07 = "ffffff";
  schemes.tomorrow-night.base08 = "cc6666";
  schemes.tomorrow-night.base09 = "de935f";
  schemes.tomorrow-night.base0A = "f0c674";
  schemes.tomorrow-night.base0B = "b5bd68";
  schemes.tomorrow-night.base0C = "8abeb7";
  schemes.tomorrow-night.base0D = "81a2be";
  schemes.tomorrow-night.base0E = "b294bb";
  schemes.tomorrow-night.base0F = "a3685a";

  rust = with pkgs.fenix;
    combine [
      stable.cargo
      stable.clippy
      stable.rust-analyzer
      stable.rust-docs
      stable.rust-src
      stable.rust-std
      stable.rustc
      stable.rustfmt

      targets.aarch64-apple-darwin.stable.rust-std
      targets.aarch64-unknown-linux-gnu.stable.rust-std
      targets.aarch64-unknown-linux-musl.stable.rust-std
      targets.wasm32-unknown-unknown.stable.rust-std
      targets.wasm32-wasip1.stable.rust-std
      targets.wasm32-wasip2.stable.rust-std
      targets.x86_64-apple-darwin.stable.rust-std
      targets.x86_64-pc-windows-gnu.stable.rust-std
      targets.x86_64-unknown-linux-gnu.stable.rust-std
      targets.x86_64-unknown-linux-musl.stable.rust-std
    ];

  neovim = hiPrio pkgs.neovim; # neovim is configured externally in an overlay

  mkXkbOptions = concatStringsSep ",";
  defaultXkbOptions = mkXkbOptions config.home.keyboard.options;
  extendDefaultXkbOptions = xs: mkXkbOptions (config.home.keyboard.options ++ xs);

  cfg = config.nixelium;
  swayConfig = config.wayland.windowManager.sway.config;

  choosePass = "${config.programs.password-store.package}/bin/gopass list --flat \${@} | ${pkgs.wofi}/bin/wofi --dmenu";
  exec = cmd: "exec '${cmd}'";
  lockCmd = "${pkgs.swaylock}/bin/swaylock -t -f -F -i ${config.home.homeDirectory}/pictures/lock";
  typeStdin = "${pkgs.ydotool}/bin/ydotool type --file -";
in {
  options.nixelium.user.email = mkOption {
    type = types.strMatching ".+@.+\..+";
    example = "foobar@example.com";
    default = "rvolosatovs@riseup.net";
    description = "User's email address";
  };

  options.nixelium.user.fullName = mkOption {
    type = types.str;
    description = "User's full name";
    default = "Roman Volosatovs";
  };

  options.nixelium.user.username = mkOption {
    type = types.str;
    description = "User's username";
    default = "rvolosatovs";
  };

  options.nixelium.base16.theme = mkOption {
    type = types.str;
    example = "tomorrow-night";
    default = "tomorrow-night";
    description = "Base16 theme name";
  };

  options.nixelium.base16.colors.base00 = mkOption {
    type = types.str;
    visible = false;
    default = schemes.${cfg.base16.theme}.base00;
  };

  options.nixelium.base16.colors.base01 = mkOption {
    type = types.str;
    visible = false;
    default = schemes.${cfg.base16.theme}.base01;
  };

  options.nixelium.base16.colors.base02 = mkOption {
    type = types.str;
    visible = false;
    default = schemes.${cfg.base16.theme}.base02;
  };

  options.nixelium.base16.colors.base03 = mkOption {
    type = types.str;
    visible = false;
    default = schemes.${cfg.base16.theme}.base03;
  };

  options.nixelium.base16.colors.base04 = mkOption {
    type = types.str;
    visible = false;
    default = schemes.${cfg.base16.theme}.base04;
  };

  options.nixelium.base16.colors.base05 = mkOption {
    type = types.str;
    visible = false;
    default = schemes.${cfg.base16.theme}.base05;
  };

  options.nixelium.base16.colors.base06 = mkOption {
    type = types.str;
    visible = false;
    default = schemes.${cfg.base16.theme}.base06;
  };

  options.nixelium.base16.colors.base07 = mkOption {
    type = types.str;
    visible = false;
    default = schemes.${cfg.base16.theme}.base07;
  };

  options.nixelium.base16.colors.base08 = mkOption {
    type = types.str;
    visible = false;
    default = schemes.${cfg.base16.theme}.base08;
  };

  options.nixelium.base16.colors.base09 = mkOption {
    type = types.str;
    visible = false;
    default = schemes.${cfg.base16.theme}.base09;
  };

  options.nixelium.base16.colors.base0A = mkOption {
    type = types.str;
    visible = false;
    default = schemes.${cfg.base16.theme}.base0A;
  };

  options.nixelium.base16.colors.base0B = mkOption {
    type = types.str;
    visible = false;
    default = schemes.${cfg.base16.theme}.base0B;
  };

  options.nixelium.base16.colors.base0C = mkOption {
    type = types.str;
    visible = false;
    default = schemes.${cfg.base16.theme}.base0C;
  };

  options.nixelium.base16.colors.base0D = mkOption {
    type = types.str;
    visible = false;
    default = schemes.${cfg.base16.theme}.base0D;
  };

  options.nixelium.base16.colors.base0E = mkOption {
    type = types.str;
    visible = false;
    default = schemes.${cfg.base16.theme}.base0E;
  };

  options.nixelium.base16.colors.base0F = mkOption {
    type = types.str;
    visible = false;
    default = schemes.${cfg.base16.theme}.base0F;
  };
  config = mkMerge [
    {
      gtk.font.name = "Fira Sans 10";
      gtk.font.package = pkgs.fira;
      gtk.iconTheme.name = "Adwaita-dark";
      gtk.iconTheme.package = pkgs.gnome-themes-extra;
      gtk.theme.name = "Adwaita-dark";
      gtk.theme.package = pkgs.gnome-themes-extra;

      gtk.gtk2.extraConfig = ''
        gtk-cursor-theme-size=0
        gtk-toolbar-style=GTK_TOOLBAR_BOTH
        gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
        gtk-button-images=1
        gtk-menu-images=1
        gtk-enable-event-sounds=1
        gtk-enable-input-feedback-sounds=1
        gtk-xft-antialias=1
        gtk-xft-hinting=1
        gtk-xft-hintstyle="hintslight"
        gtk-xft-rgba="rgb"
      '';

      gtk.gtk3.extraConfig.gtk-cursor-theme-size = 0;
      gtk.gtk3.extraConfig.gtk-toolbar-style = "GTK_TOOLBAR_BOTH";
      gtk.gtk3.extraConfig.gtk-toolbar-icon-size = "GTK_ICON_SIZE_LARGE_TOOLBAR";
      gtk.gtk3.extraConfig.gtk-button-images = 1;
      gtk.gtk3.extraConfig.gtk-menu-images = 1;
      gtk.gtk3.extraConfig.gtk-enable-event-sounds = 1;
      gtk.gtk3.extraConfig.gtk-enable-input-feedback-sounds = 1;
      gtk.gtk3.extraConfig.gtk-xft-antialias = 1;
      gtk.gtk3.extraConfig.gtk-xft-hinting = 1;
      gtk.gtk3.extraConfig.gtk-xft-hintstyle = "hintslight";
      gtk.gtk3.extraConfig.gtk-xft-rgba = "rgb";
      gtk.gtk3.extraCss = ''
        /* remove window title from Client-Side Decorations */
        .solid-csd headerbar .title {
            font-size: 0;
        }

        /* hide extra window decorations/double border */
        window decoration {
            margin: 0;
            border: none;
            padding: 0;
        }
      '';
      home.keyboard.layout = "lv,ru";
      home.keyboard.options = [
        "eurosign:5"
        "grp:alt_space_toggle"
      ];

      home.packages = [
        neovim

        pkgs.curl
        pkgs.entr
        pkgs.fd
        pkgs.file
        pkgs.findutils
        pkgs.git-rebase-all
        pkgs.gnumake
        pkgs.jq
        pkgs.kitty.terminfo
        pkgs.lsof
        pkgs.nix-prefetch-scripts
        pkgs.openssl
        pkgs.pciutils
        pkgs.pv
        pkgs.qrencode
        pkgs.rclone
        pkgs.ripgrep
        pkgs.scrcpy
        pkgs.tree
        pkgs.unzip
        pkgs.wget
        pkgs.xxd
        pkgs.zip
      ];

      home.sessionVariables.CLICOLOR = "1";
      home.sessionVariables.DO_NOT_TRACK = "1"; # https://consoledonottrack.com/
      home.sessionVariables.ELINKS_CONFDIR = "${config.xdg.configHome}/elinks";
      home.sessionVariables.GIMP2_DIRECTORY = "${config.xdg.configHome}/gimp";
      home.sessionVariables.LSCOLORS = "ExGxFxdaCxDaDahbadacec";
      home.sessionVariables.MANPAGER = "${pkgs.neovim}/bin/nvim +Man!";
      home.sessionVariables.NAVI_FINDER = "skim";
      home.sessionVariables.PYTHON_EGG_CACHE = "${config.xdg.cacheHome}/python-eggs";
      home.sessionVariables.WINEPREFIX = "${config.xdg.dataHome}/wine";

      home.shellAliases."gcf^" = "git commit --fixup HEAD^";
      home.shellAliases.ga = "git add";
      home.shellAliases.gap = "git add -p";
      home.shellAliases.gb = "git branch";
      home.shellAliases.gB = "git rebase";
      home.shellAliases.gBa = "git rebase --abort";
      home.shellAliases.gBc = "git rebase --continue";
      home.shellAliases.gBI = "git rebase -i --no-autosquash";
      home.shellAliases.gBi = "git rebase -i";
      home.shellAliases.gBs = "git rebase --skip";
      home.shellAliases.gc = "git commit";
      home.shellAliases.gca = "git commit --amend";
      home.shellAliases.gcf = "git commit --fixup";
      home.shellAliases.gcm = "git commit -m";
      home.shellAliases.gd = "git diff";
      home.shellAliases.gdc = "git diff --cached";
      home.shellAliases.gf = "git fetch";
      home.shellAliases.gfa = "git fetch --all";
      home.shellAliases.gfp = "git fetch --prune";
      home.shellAliases.gfpa = "git fetch --prune --all";
      home.shellAliases.gL = "git log --patch-with-stat";
      home.shellAliases.gl = "git log --stat --date=short";
      home.shellAliases.gLd = "git log --patch-with-stat --reverse";
      home.shellAliases.gLdo = "git log --patch-with-stat --reverse origin/master..HEAD";
      home.shellAliases.gLdu = "git log --patch-with-stat --reverse upstream/master..HEAD";
      home.shellAliases.glr = "git reflog";
      home.shellAliases.gm = "git cherry-pick";
      home.shellAliases.gM = "git merge";
      home.shellAliases.gma = "git cherry-pick --abort";
      home.shellAliases.gMa = "git merge --abort";
      home.shellAliases.gmc = "git cherry-pick --continue";
      home.shellAliases.gms = "git cherry-pick --skip";
      home.shellAliases.gn = "git checkout";
      home.shellAliases.gnb = "git checkout -b";
      home.shellAliases.gno = "git checkout --orphan";
      home.shellAliases.gp = "git pull";
      home.shellAliases.gP = "git push";
      home.shellAliases.gpp = "git pull --prune";
      home.shellAliases.gPp = "git push --prune";
      home.shellAliases.gr = "git remote";
      home.shellAliases.gR = "git reset";
      home.shellAliases.gra = "git remote add";
      home.shellAliases.gRh = "git reset --hard";
      home.shellAliases.grl = "git reflog";
      home.shellAliases.gS = "git show";
      home.shellAliases.gs = "git status";
      home.shellAliases.gT = "git tag";
      home.shellAliases.gt = "git tree";
      home.shellAliases.gtt = "git tree --all";
      home.shellAliases.gy = "git stash";
      home.shellAliases.gyd = "git stash drop";
      home.shellAliases.gyp = "git stash pop";
      home.shellAliases.mkdir = "mkdir -pv";
      home.shellAliases.rm = "rm -i";
      home.shellAliases.sl = "ls";

      nix.registry.nixelium.flake = self;
      nix.registry.nixelium.from.id = "nixelium";
      nix.registry.nixelium.from.type = "indirect";

      nix.registry.nixify.flake = nixify;
      nix.registry.nixify.from.id = "nixify";
      nix.registry.nixify.from.type = "indirect";

      nix.registry.nixlib.flake = nixlib;
      nix.registry.nixlib.from.id = "nixlib";
      nix.registry.nixlib.from.type = "indirect";

      nix.registry.nixpkgs-darwin.flake = nixpkgs-darwin;
      nix.registry.nixpkgs-darwin.from.id = "nixpkgs-darwin";
      nix.registry.nixpkgs-darwin.from.type = "indirect";

      nix.registry.nixpkgs-nixos.flake = nixpkgs-nixos;
      nix.registry.nixpkgs-nixos.from.id = "nixpkgs-nixos";
      nix.registry.nixpkgs-nixos.from.type = "indirect";

      nix.registry.nixpkgs-unstable.flake = nixpkgs-unstable;
      nix.registry.nixpkgs-unstable.from.id = "nixpkgs-unstable";
      nix.registry.nixpkgs-unstable.from.type = "indirect";

      programs.bash.enable = true;
      programs.bash.enableCompletion = true;
      programs.bash.historyControl = [
        "erasedups"
        "ignoredups"
        "ignorespace"
      ];

      programs.bat.config.theme = "base16";
      programs.bat.enable = true;
      programs.bat.extraPackages = [
        pkgs.bat-extras.batdiff
        pkgs.bat-extras.batgrep
        pkgs.bat-extras.batman
        pkgs.bat-extras.batwatch
        pkgs.bat-extras.prettybat
      ];

      programs.chromium.extensions = [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock origin
        "clngdbkpkpeebahjckkjfobafhncgmne" # stylus
        "dbepggeogbaibhgnhhndojpepiihcmeb" # vimium
        "klbibkeccnjlkjkiokjodocebajanakg" # great suspender
      ];

      programs.dircolors.enable = true;
      programs.dircolors.settings.".7z" = "01;31";
      programs.dircolors.settings.".aac" = "00;36";
      programs.dircolors.settings.".ace" = "01;31";
      programs.dircolors.settings.".alz" = "01;31";
      programs.dircolors.settings.".arc" = "01;31";
      programs.dircolors.settings.".arj" = "01;31";
      programs.dircolors.settings.".asf" = "01;35";
      programs.dircolors.settings.".au" = "00;36";
      programs.dircolors.settings.".avi" = "01;35";
      programs.dircolors.settings.".bmp" = "01;35";
      programs.dircolors.settings.".bz" = "01;31";
      programs.dircolors.settings.".bz2" = "01;31";
      programs.dircolors.settings.".cab" = "01;31";
      programs.dircolors.settings.".cgm" = "01;35";
      programs.dircolors.settings.".cpio" = "01;31";
      programs.dircolors.settings.".deb" = "01;31";
      programs.dircolors.settings.".dl" = "01;35";
      programs.dircolors.settings.".dwm" = "01;31";
      programs.dircolors.settings.".dz" = "01;31";
      programs.dircolors.settings.".ear" = "01;31";
      programs.dircolors.settings.".emf" = "01;35";
      programs.dircolors.settings.".esd" = "01;31";
      programs.dircolors.settings.".flac" = "00;36";
      programs.dircolors.settings.".flc" = "01;35";
      programs.dircolors.settings.".fli" = "01;35";
      programs.dircolors.settings.".flv" = "01;35";
      programs.dircolors.settings.".gif" = "01;35";
      programs.dircolors.settings.".gl" = "01;35";
      programs.dircolors.settings.".gz" = "01;31";
      programs.dircolors.settings.".jar" = "01;31";
      programs.dircolors.settings.".jpeg" = "01;35";
      programs.dircolors.settings.".jpg" = "01;35";
      programs.dircolors.settings.".lha" = "01;31";
      programs.dircolors.settings.".lrz" = "01;31";
      programs.dircolors.settings.".lz" = "01;31";
      programs.dircolors.settings.".lz4" = "01;31";
      programs.dircolors.settings.".lzh" = "01;31";
      programs.dircolors.settings.".lzma" = "01;31";
      programs.dircolors.settings.".lzo" = "01;31";
      programs.dircolors.settings.".m2v" = "01;35";
      programs.dircolors.settings.".m4a" = "00;36";
      programs.dircolors.settings.".m4v" = "01;35";
      programs.dircolors.settings.".mid" = "00;36";
      programs.dircolors.settings.".midi" = "00;36";
      programs.dircolors.settings.".mjpeg" = "01;35";
      programs.dircolors.settings.".mjpg" = "01;35";
      programs.dircolors.settings.".mka" = "00;36";
      programs.dircolors.settings.".mkv" = "01;35";
      programs.dircolors.settings.".mng" = "01;35";
      programs.dircolors.settings.".mov" = "01;35";
      programs.dircolors.settings.".mp3" = "00;36";
      programs.dircolors.settings.".mp4" = "01;35";
      programs.dircolors.settings.".mp4v" = "01;35";
      programs.dircolors.settings.".mpc" = "00;36";
      programs.dircolors.settings.".mpeg" = "01;35";
      programs.dircolors.settings.".mpg" = "01;35";
      programs.dircolors.settings.".nuv" = "01;35";
      programs.dircolors.settings.".oga" = "00;36";
      programs.dircolors.settings.".ogg" = "00;36";
      programs.dircolors.settings.".ogm" = "01;35";
      programs.dircolors.settings.".ogv" = "01;35";
      programs.dircolors.settings.".ogx" = "01;35";
      programs.dircolors.settings.".opus" = "00;36";
      programs.dircolors.settings.".pbm" = "01;35";
      programs.dircolors.settings.".pcx" = "01;35";
      programs.dircolors.settings.".pgm" = "01;35";
      programs.dircolors.settings.".png" = "01;35";
      programs.dircolors.settings.".ppm" = "01;35";
      programs.dircolors.settings.".qt" = "01;35";
      programs.dircolors.settings.".ra" = "00;36";
      programs.dircolors.settings.".rar" = "01;31";
      programs.dircolors.settings.".rm" = "01;35";
      programs.dircolors.settings.".rmvb" = "01;35";
      programs.dircolors.settings.".rpm" = "01;31";
      programs.dircolors.settings.".rz" = "01;31";
      programs.dircolors.settings.".sar" = "01;31";
      programs.dircolors.settings.".spx" = "00;36";
      programs.dircolors.settings.".svg" = "01;35";
      programs.dircolors.settings.".svgz" = "01;35";
      programs.dircolors.settings.".swm" = "01;31";
      programs.dircolors.settings.".t7z" = "01;31";
      programs.dircolors.settings.".tar" = "01;31";
      programs.dircolors.settings.".taz" = "01;31";
      programs.dircolors.settings.".tbz" = "01;31";
      programs.dircolors.settings.".tbz2" = "01;31";
      programs.dircolors.settings.".tga" = "01;35";
      programs.dircolors.settings.".tgz" = "01;31";
      programs.dircolors.settings.".tif" = "01;35";
      programs.dircolors.settings.".tiff" = "01;35";
      programs.dircolors.settings.".tlz" = "01;31";
      programs.dircolors.settings.".txz" = "01;31";
      programs.dircolors.settings.".tz" = "01;31";
      programs.dircolors.settings.".tzo" = "01;31";
      programs.dircolors.settings.".tzst" = "01;31";
      programs.dircolors.settings.".vob" = "01;35";
      programs.dircolors.settings.".war" = "01;31";
      programs.dircolors.settings.".wav" = "00;36";
      programs.dircolors.settings.".webm" = "01;35";
      programs.dircolors.settings.".wim" = "01;31";
      programs.dircolors.settings.".wmv" = "01;35";
      programs.dircolors.settings.".xbm" = "01;35";
      programs.dircolors.settings.".xcf" = "01;35";
      programs.dircolors.settings.".xpm" = "01;35";
      programs.dircolors.settings.".xspf" = "00;36";
      programs.dircolors.settings.".xwd" = "01;35";
      programs.dircolors.settings.".xz" = "01;31";
      programs.dircolors.settings.".yuv" = "01;35";
      programs.dircolors.settings.".z" = "01;31";
      programs.dircolors.settings.".zip" = "01;31";
      programs.dircolors.settings.".zoo" = "01;31";
      programs.dircolors.settings.".zst" = "01;31";
      programs.dircolors.settings.bd = "40;33;01";
      programs.dircolors.settings.ca = "30;41";
      programs.dircolors.settings.cd = "40;33;01";
      programs.dircolors.settings.di = "01;34";
      programs.dircolors.settings.do = "01;35";
      programs.dircolors.settings.ex = "01;32";
      programs.dircolors.settings.ln = "01;36";
      programs.dircolors.settings.mh = "00";
      programs.dircolors.settings.mi = "00";
      programs.dircolors.settings.or = "40;31;01";
      programs.dircolors.settings.ow = "34;42";
      programs.dircolors.settings.pi = "40;33";
      programs.dircolors.settings.rs = "0";
      programs.dircolors.settings.sg = "30;43";
      programs.dircolors.settings.so = "01;35";
      programs.dircolors.settings.st = "37;44";
      programs.dircolors.settings.su = "37;41";
      programs.dircolors.settings.tw = "30;42";

      programs.direnv.enable = true;
      programs.direnv.enableBashIntegration = true;
      programs.direnv.enableZshIntegration = true;
      programs.direnv.nix-direnv.enable = true;

      programs.eza.enable = true;
      programs.eza.enableBashIntegration = true;
      programs.eza.enableZshIntegration = true;
      programs.eza.git = true;

      programs.git.aliases.tree = "log --graph --pretty=format:'%C(auto)%h - %s [%an] (%C(blue)%ar)%C(auto)%d'";
      programs.git.delta.enable = true;
      programs.git.delta.options.syntax-theme = "base16";
      programs.git.enable = true;
      programs.git.extraConfig.branch.autosetupmerge = false;
      programs.git.extraConfig.branch.autosetuprebase = "always";
      programs.git.extraConfig.color.ui = true;
      programs.git.extraConfig.core.autocrlf = false;
      programs.git.extraConfig.core.safecrlf = false;
      programs.git.extraConfig.diff.colorMoved = "zebra";
      programs.git.extraConfig.diff.renames = "copy";
      programs.git.extraConfig.fetch.prune = true;
      programs.git.extraConfig.format.pretty = "%C(auto)%h - %s%d%n%+b%+N(%G?) %an <%ae> (%C(blue)%ad%C(auto))%n";
      programs.git.extraConfig.hub.protocol = "https";
      programs.git.extraConfig.init.defaultBranch = "main";
      programs.git.extraConfig.merge.conflictstyle = "diff3";
      programs.git.extraConfig.pull.rebase = "true";
      programs.git.extraConfig.push.default = "nothing";
      programs.git.extraConfig.rebase.autosquash = true;
      programs.git.extraConfig.rerere.enabled = true;
      programs.git.extraConfig.status.branch = true;
      programs.git.extraConfig.status.short = true;
      programs.git.extraConfig.status.showUntrackedFiles = "all";
      programs.git.extraConfig.status.submoduleSummary = true;
      programs.git.ignores = [
        "*.aux"
        "*.dvi"
        "*.ear"
        "*.jar"
        "*.log"
        "*.out"
        "*.pdf"
        "*.rar"
        "*.sql"
        "*.sqlite"
        "*.tar.gz"
        "*.test"
        "*.war"
        "*.zip"
        "*~"
        "._*"
        ".ccls-cache/"
        ".direnv*"
        ".DS_Store"
        ".DS_Store?"
        ".envrc*"
        ".Spotlight-V100"
        ".Trashes"
        ".vscode"
        "ehthumbs.db"
        "result"
        "Thumbs.db"
        "token"
      ];
      programs.git.signing.key = null; # let gpg decide at runtime
      programs.git.signing.signByDefault = true;
      programs.git.userEmail = cfg.user.email;
      programs.git.userName = cfg.user.fullName;

      programs.go.goPath = "";
      programs.go.goBin = ".local/bin.go";

      programs.gpg.enable = true;
      programs.gpg.scdaemonSettings.disable-ccid = true;
      programs.gpg.settings.cert-digest-algo = "SHA512";
      programs.gpg.settings.cipher-algo = "AES256";
      programs.gpg.settings.compress-algo = "ZLIB";
      programs.gpg.settings.default-preference-list = "SHA512 SHA384 SHA256 RIPEMD160 AES256 TWOFISH BLOWFISH ZLIB BZIP2 ZIP Uncompressed";
      programs.gpg.settings.default-recipient-self = true;
      programs.gpg.settings.digest-algo = "SHA512";
      programs.gpg.settings.disable-cipher-algo = "3DES";
      programs.gpg.settings.export-options = "export-minimal";
      programs.gpg.settings.keyid-format = "0xlong";
      programs.gpg.settings.keyserver-options = "auto-key-retrieve";
      programs.gpg.settings.list-options = "show-uid-validity";
      programs.gpg.settings.no-comments = true;
      programs.gpg.settings.no-emit-version = true;
      programs.gpg.settings.no-greeting = true;
      programs.gpg.settings.personal-cipher-preferences = "AES256";
      programs.gpg.settings.personal-digest-preferences = "SHA512";
      programs.gpg.settings.s2k-cipher-algo = "AES256";
      programs.gpg.settings.s2k-count = "65011712";
      programs.gpg.settings.s2k-digest-algo = "SHA512";
      programs.gpg.settings.s2k-mode = "3";
      programs.gpg.settings.use-agent = true;
      programs.gpg.settings.verify-options = "show-uid-validity";
      programs.gpg.settings.weak-digest = "SHA1";
      programs.gpg.settings.with-fingerprint = true;

      programs.home-manager.enable = true;

      programs.htop.enable = true;

      # Colors based on https://github.com/kdrag0n/base16-kitty/blob/742d0326db469cae2b77ede3e10bedc323a41547/templates/default-256.mustache#L3-L42
      programs.kitty.settings.color0 = "#${cfg.base16.colors.base00}";
      programs.kitty.settings.color1 = "#${cfg.base16.colors.base08}";
      programs.kitty.settings.color2 = "#${cfg.base16.colors.base0B}";
      programs.kitty.settings.color3 = "#${cfg.base16.colors.base0A}";
      programs.kitty.settings.color4 = "#${cfg.base16.colors.base0D}";
      programs.kitty.settings.color5 = "#${cfg.base16.colors.base0E}";
      programs.kitty.settings.color6 = "#${cfg.base16.colors.base0C}";
      programs.kitty.settings.color7 = "#${cfg.base16.colors.base05}";
      programs.kitty.settings.color8 = "#${cfg.base16.colors.base03}";
      programs.kitty.settings.color9 = "#${cfg.base16.colors.base08}";

      programs.kitty.settings.color10 = "#${cfg.base16.colors.base0B}";
      programs.kitty.settings.color11 = "#${cfg.base16.colors.base0A}";
      programs.kitty.settings.color12 = "#${cfg.base16.colors.base0D}";
      programs.kitty.settings.color13 = "#${cfg.base16.colors.base0E}";
      programs.kitty.settings.color14 = "#${cfg.base16.colors.base0C}";
      programs.kitty.settings.color15 = "#${cfg.base16.colors.base05}";
      programs.kitty.settings.color16 = "#${cfg.base16.colors.base09}";
      programs.kitty.settings.color17 = "#${cfg.base16.colors.base0F}";
      programs.kitty.settings.color18 = "#${cfg.base16.colors.base01}";
      programs.kitty.settings.color19 = "#${cfg.base16.colors.base02}";
      programs.kitty.settings.color20 = "#${cfg.base16.colors.base04}";
      programs.kitty.settings.color21 = "#${cfg.base16.colors.base06}";

      programs.kitty.settings.active_border_color = "#${cfg.base16.colors.base03}";
      programs.kitty.settings.active_tab_background = "#${cfg.base16.colors.base00}";
      programs.kitty.settings.active_tab_foreground = "#${cfg.base16.colors.base05}";
      programs.kitty.settings.background = "#${cfg.base16.colors.base00}";
      programs.kitty.settings.cursor = "#${cfg.base16.colors.base05}";
      programs.kitty.settings.cursor_blink_interval = 0;
      programs.kitty.settings.cursor_shape = "underline";
      programs.kitty.settings.disable_ligatures = "cursor";
      programs.kitty.settings.foreground = "#${cfg.base16.colors.base05}";
      programs.kitty.settings.hide_window_decorations = true;
      programs.kitty.settings.inactive_border_color = "#${cfg.base16.colors.base01}";
      programs.kitty.settings.inactive_tab_background = "#${cfg.base16.colors.base01}";
      programs.kitty.settings.inactive_tab_foreground = "#${cfg.base16.colors.base04}";
      programs.kitty.settings.macos_option_as_alt = true;
      programs.kitty.settings.selection_background = "#${cfg.base16.colors.base05}";
      programs.kitty.settings.selection_foreground = "#${cfg.base16.colors.base00}";
      programs.kitty.settings.tab_bar_edge = "top";
      programs.kitty.settings.url_color = "#${cfg.base16.colors.base04}";

      programs.kitty.font.name = "Fira Code";
      programs.kitty.font.package = pkgs.fira-code;
      programs.kitty.shellIntegration.mode = "no-cursor";
      programs.kitty.themeFile = "Tomorrow_Night";

      programs.mpv.config.alang = "eng,en,rus,ru";

      programs.neovim.defaultEditor = true;
      programs.neovim.enable = true;
      programs.neovim.viAlias = true;
      programs.neovim.vimAlias = true;
      programs.neovim.vimdiffAlias = true;

      programs.password-store.package = pkgs.gopass;
      programs.password-store.settings.PASSWORD_STORE_DIR = "${config.xdg.dataHome}/password-store";

      programs.readline.bindings.Control-j = "menu-complete";
      programs.readline.bindings.Control-k = "menu-complete-backward";
      programs.readline.enable = true;
      programs.readline.extraConfig = ''
        set editing-mode vi
        $if term=linux
            set vi-ins-mode-string \1\e[?0c\2
            set vi-cmd-mode-string \1\e[?8c\2
        $else
            set vi-ins-mode-string \1\e[4 q\2
            set vi-cmd-mode-string \1\e[2 q\2
        $endif
      '';
      programs.readline.variables.colored-completion-prefix = true;
      programs.readline.variables.colored-stats = true;
      programs.readline.variables.completion-ignore-case = true;
      programs.readline.variables.completion-map-case = true;
      programs.readline.variables.completion-prefix-display-length = 2;
      programs.readline.variables.mark-symlinked-directories = true;
      programs.readline.variables.menu-complete-display-prefix = true;
      programs.readline.variables.show-all-if-ambiguous = true;
      programs.readline.variables.show-all-if-unmodified = true;
      programs.readline.variables.show-mode-in-prompt = true;
      programs.readline.variables.visible-stats = true;

      programs.skim.enable = true;
      programs.skim.changeDirWidgetCommand = "${pkgs.fd}/bin/fd -H --color=always --type d";
      programs.skim.defaultCommand = "${pkgs.fd}/bin/fd -H --color=always --type f";
      programs.skim.defaultOptions = [
        "--ansi"
        "--bind='ctrl-e:execute(\${EDITOR:-${pkgs.neovim}/bin/nvim} {})'"
      ];
      programs.skim.enableBashIntegration = true;
      programs.skim.enableZshIntegration = true;
      programs.skim.fileWidgetCommand = "${pkgs.fd}/bin/fd -H --color=always --type f --exclude '.git'";
      programs.skim.fileWidgetOptions = [
        "--preview '${pkgs.bat}/bin/bat --color=always {}'"
      ];

      programs.ssh.enable = true;
      programs.ssh.compression = true;
      programs.ssh.serverAliveInterval = 5;
      programs.ssh.matchBlocks."*.labs.overthewire.org".extraOptions.SendEnv = "OTWUSERDIR";
      programs.ssh.matchBlocks."github.com".extraOptions.Ciphers = "chacha20-poly1305@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr,aes256-cbc,aes192-cbc,aes128-cbc";
      programs.ssh.matchBlocks."github.com".extraOptions.KexAlgorithms = "curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group14-sha1,diffie-hellman-group1-sha1";
      programs.ssh.matchBlocks."github.com".extraOptions.MACs = "hmac-sha2-256,hmac-sha2-512,hmac-sha1";

      programs.thunderbird.profiles.main.isDefault = true;
      programs.thunderbird.profiles.main.withExternalGnupg = true;

      # TODO: Configure
      programs.waybar.settings.default."sway/mode".format = "<span style=\"italic\">{}</span>";
      programs.waybar.settings.default.backlight.format = "{percent}% {icon}";
      programs.waybar.settings.default.backlight.format-icons = ["" ""];
      programs.waybar.settings.default.battery.format = "{capacity}% {icon}";
      programs.waybar.settings.default.battery.format-alt = "{time} {icon}";
      programs.waybar.settings.default.battery.format-charging = "{capacity}% ";
      programs.waybar.settings.default.battery.format-icons = ["" "" "" "" ""];
      programs.waybar.settings.default.battery.format-plugged = "{capacity}% ";
      programs.waybar.settings.default.battery.states.critical = 15;
      programs.waybar.settings.default.battery.states.good = 75;
      programs.waybar.settings.default.battery.states.warning = 30;
      programs.waybar.settings.default.clock.format-alt = "{:%Y-%m-%d}";
      programs.waybar.settings.default.clock.tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      programs.waybar.settings.default.cpu.format = "{usage}% ";
      programs.waybar.settings.default.idle_inhibitor.format = "{icon}";
      programs.waybar.settings.default.idle_inhibitor.format-icons.activated = "";
      programs.waybar.settings.default.idle_inhibitor.format-icons.deactivated = "";
      programs.waybar.settings.default.memory.format = "{}% ";
      programs.waybar.settings.default.modules-center = ["sway/window"];
      programs.waybar.settings.default.modules-left = ["sway/workspaces" "sway/mode"];
      programs.waybar.settings.default.modules-right = ["idle_inhibitor" "pulseaudio" "network" "cpu" "memory" "backlight" "battery" "clock" "tray"];
      programs.waybar.settings.default.network.format-alt = "{ifname}: {ipaddr}/{cidr}";
      programs.waybar.settings.default.network.format-disconnected = "Disconnected ⚠";
      programs.waybar.settings.default.network.format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
      programs.waybar.settings.default.network.format-linked = "{ifname} (No IP) ";
      programs.waybar.settings.default.network.format-wifi = "{essid} ({signalStrength}%) ";
      programs.waybar.settings.default.pulseaudio.format = "{volume}% {icon} {format_source}";
      programs.waybar.settings.default.pulseaudio.format-bluetooth = "{volume}% {icon} {format_source}";
      programs.waybar.settings.default.pulseaudio.format-bluetooth-muted = " {icon} {format_source}";
      programs.waybar.settings.default.pulseaudio.format-icons.car = "";
      programs.waybar.settings.default.pulseaudio.format-icons.default = ["" "" ""];
      programs.waybar.settings.default.pulseaudio.format-icons.hands-free = "";
      programs.waybar.settings.default.pulseaudio.format-icons.headphone = "";
      programs.waybar.settings.default.pulseaudio.format-icons.headset = "";
      programs.waybar.settings.default.pulseaudio.format-icons.phone = "";
      programs.waybar.settings.default.pulseaudio.format-icons.portable = "";
      programs.waybar.settings.default.pulseaudio.format-muted = " {format_source}";
      programs.waybar.settings.default.pulseaudio.format-source = "{volume}% ";
      programs.waybar.settings.default.pulseaudio.format-source-muted = "";
      programs.waybar.settings.default.pulseaudio.on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
      programs.waybar.settings.default.tray.spacing = 10;

      programs.waybar.systemd.enable = true; # TODO: Enable
      programs.waybar.systemd.target = "sway-session.target";

      programs.zathura.options.completion-bg = "#${cfg.base16.colors.base02}";
      programs.zathura.options.completion-fg = "#${cfg.base16.colors.base0C}";
      programs.zathura.options.completion-highlight-bg = "#${cfg.base16.colors.base0C}";
      programs.zathura.options.completion-highlight-fg = "#${cfg.base16.colors.base02}";
      programs.zathura.options.default-bg = "#${cfg.base16.colors.base00}";
      programs.zathura.options.default-fg = "#${cfg.base16.colors.base01}";
      programs.zathura.options.highlight-active-color = "#${cfg.base16.colors.base0D}";
      programs.zathura.options.highlight-color = "#${cfg.base16.colors.base0A}";
      programs.zathura.options.index-active-bg = "#${cfg.base16.colors.base0D}";
      programs.zathura.options.inputbar-bg = "#${cfg.base16.colors.base00}";
      programs.zathura.options.inputbar-fg = "#${cfg.base16.colors.base05}";
      programs.zathura.options.notification-bg = "#${cfg.base16.colors.base0B}";
      programs.zathura.options.notification-error-bg = "#${cfg.base16.colors.base08}";
      programs.zathura.options.notification-error-fg = "#${cfg.base16.colors.base00}";
      programs.zathura.options.notification-fg = "#${cfg.base16.colors.base00}";
      programs.zathura.options.notification-warning-bg = "#${cfg.base16.colors.base08}";
      programs.zathura.options.notification-warning-fg = "#${cfg.base16.colors.base00}";
      programs.zathura.options.recolor = true;
      programs.zathura.options.recolor-darkcolor = "#${cfg.base16.colors.base06}";
      programs.zathura.options.recolor-keephue = true;
      programs.zathura.options.recolor-lightcolor = "#${cfg.base16.colors.base00}";
      programs.zathura.options.selection-clipboard = "clipboard";
      programs.zathura.options.statusbar-bg = "#${cfg.base16.colors.base01}";
      programs.zathura.options.statusbar-fg = "#${cfg.base16.colors.base04}";

      programs.zsh.autocd = true;
      programs.zsh.cdpath = [
        "${config.home.homeDirectory}/src/github.com/${cfg.user.username}"
        "${config.home.homeDirectory}/src/github.com/wrpc"
        "${config.home.homeDirectory}/src/github.com/cosmonic"
        "${config.home.homeDirectory}/src/github.com/wasmCloud"
        "${config.home.homeDirectory}/src/github.com/WebAssembly"
        "${config.home.homeDirectory}/src/github.com/bytecodealliance"
        "${config.home.homeDirectory}/src/github.com/NixOS"
        "${config.home.homeDirectory}/src/github.com/nix-community"
        "${config.home.homeDirectory}/src/github.com"
        "${config.home.homeDirectory}/src"
      ];
      programs.zsh.defaultKeymap = "viins";
      programs.zsh.dotDir = ".config/zsh";
      programs.zsh.enable = true;
      programs.zsh.autosuggestion.enable = !(osConfig.programs.zsh.autosuggestions.enable or false);
      programs.zsh.enableCompletion = false;
      programs.zsh.syntaxHighlighting.enable = !(osConfig.programs.zsh.syntaxHighlighting.enable or false);
      programs.zsh.history.expireDuplicatesFirst = true;
      programs.zsh.history.ignoreAllDups = true;
      programs.zsh.history.ignoreDups = true;
      programs.zsh.history.save = osConfig.programs.zsh.histSize or 50000;
      programs.zsh.history.size = osConfig.programs.zsh.histSize or 50000;
      programs.zsh.historySubstringSearch.enable = true;
      programs.zsh.initContent = mkMerge [
        (mkBefore "source '${pkgs.grml-zsh-config}/etc/zsh/zshrc'")
        ''
          nixify() {
            if [ ! -e ./.envrc ]; then
              echo 'use flake' > .envrc
            fi
            nix flake new . -t "github:rvolosatovs/templates#''${1:-default}"
            direnv allow
          }

          base16_tomorrow-night

          zstyle ':completion:*' completer _complete _correct _approximate
          zstyle ':completion:*' completer _expand_alias _complete _approximate
          zstyle ':completion:*' expand prefix suffix
          zstyle ':prompt:grml:right:setup' items

          bindkey -M isearch . self-insert
          bindkey -M menuselect 'h' vi-backward-char
          bindkey -M menuselect 'j' vi-down-line-or-history
          bindkey -M menuselect 'k' vi-up-line-or-history
          bindkey -M menuselect 'l' vi-forward-char
        ''
      ];

      programs.zsh.plugins = [
        {
          name = "base16-shell";
          src = base16-shell;
        }
      ];
      programs.zsh.sessionVariables.KEYTIMEOUT = "1";
      programs.zsh.shellAliases.bd = "popd";
      programs.zsh.shellAliases.dh = "dirs -v";
      programs.zsh.shellAliases.nd = "pushd";

      qt.platformTheme = "gtk"; # TODO: Switch to qtct once supported
      qt.style.name = "adwaita-dark";

      services.clipman.systemdTarget = "sway-session.target";

      services.gpg-agent.defaultCacheTtl = 180000;
      services.gpg-agent.defaultCacheTtlSsh = 180000;
      services.gpg-agent.enableScDaemon = true;
      services.gpg-agent.enableSshSupport = true;
      services.gpg-agent.grabKeyboardAndMouse = false;

      services.kbfs.mountPoint = ".local/keybase";

      services.mako.settings."urgency=high".background-color = "#${cfg.base16.colors.base00}";
      services.mako.settings."urgency=high".border-color = "#${cfg.base16.colors.base0D}";
      services.mako.settings."urgency=high".text-color = "#${cfg.base16.colors.base08}";
      services.mako.settings."urgency=low".background-color = "#${cfg.base16.colors.base00}";
      services.mako.settings."urgency=low".border-color = "#${cfg.base16.colors.base0D}";
      services.mako.settings."urgency=low".text-color = "#${cfg.base16.colors.base0A}";
      services.mako.settings.background-color = "#${cfg.base16.colors.base00}";
      services.mako.settings.border-color = "#${cfg.base16.colors.base0D}";
      services.mako.settings.default-timeout = 5000;
      services.mako.settings.font = "monospace 10";
      services.mako.settings.text-color = "#${cfg.base16.colors.base05}";

      services.swayidle.events = [
        {
          event = "before-sleep";
          command = lockCmd;
        }
      ];
      services.swayidle.timeouts = [
        {
          timeout = 300;
          command = "swaymsg 'output * power off'";
          resumeCommand = "swaymsg 'output * power on'";
        }
      ];

      services.wlsunset.latitude = toString osConfig.location.latitude;
      services.wlsunset.longitude = toString osConfig.location.longitude;
      services.wlsunset.systemdTarget = "sway-session.target";

      wayland.windowManager.sway.config.bars = [];
      # Based on https://github.com/khamer/base16-i3/blob/78292138812a3f88c3fc4794f615f5b36b0b6d7c/templates/default.mustache#L41-L48
      wayland.windowManager.sway.config.colors.background = "#${cfg.base16.colors.base07}";
      wayland.windowManager.sway.config.colors.focused.background = "#${cfg.base16.colors.base0D}";
      wayland.windowManager.sway.config.colors.focused.border = "#${cfg.base16.colors.base05}";
      wayland.windowManager.sway.config.colors.focused.childBorder = "#${cfg.base16.colors.base0C}";
      wayland.windowManager.sway.config.colors.focused.indicator = "#${cfg.base16.colors.base0D}";
      wayland.windowManager.sway.config.colors.focused.text = "#${cfg.base16.colors.base00}";
      wayland.windowManager.sway.config.colors.focusedInactive.background = "#${cfg.base16.colors.base01}";
      wayland.windowManager.sway.config.colors.focusedInactive.border = "#${cfg.base16.colors.base01}";
      wayland.windowManager.sway.config.colors.focusedInactive.childBorder = "#${cfg.base16.colors.base01}";
      wayland.windowManager.sway.config.colors.focusedInactive.indicator = "#${cfg.base16.colors.base03}";
      wayland.windowManager.sway.config.colors.focusedInactive.text = "#${cfg.base16.colors.base05}";
      wayland.windowManager.sway.config.colors.placeholder.background = "#${cfg.base16.colors.base00}";
      wayland.windowManager.sway.config.colors.placeholder.border = "#${cfg.base16.colors.base00}";
      wayland.windowManager.sway.config.colors.placeholder.childBorder = "#${cfg.base16.colors.base00}";
      wayland.windowManager.sway.config.colors.placeholder.indicator = "#${cfg.base16.colors.base00}";
      wayland.windowManager.sway.config.colors.placeholder.text = "#${cfg.base16.colors.base05}";
      wayland.windowManager.sway.config.colors.unfocused.background = "#${cfg.base16.colors.base00}";
      wayland.windowManager.sway.config.colors.unfocused.border = "#${cfg.base16.colors.base01}";
      wayland.windowManager.sway.config.colors.unfocused.childBorder = "#${cfg.base16.colors.base01}";
      wayland.windowManager.sway.config.colors.unfocused.indicator = "#${cfg.base16.colors.base01}";
      wayland.windowManager.sway.config.colors.unfocused.text = "#${cfg.base16.colors.base05}";
      wayland.windowManager.sway.config.colors.urgent.background = "#${cfg.base16.colors.base08}";
      wayland.windowManager.sway.config.colors.urgent.border = "#${cfg.base16.colors.base08}";
      wayland.windowManager.sway.config.colors.urgent.childBorder = "#${cfg.base16.colors.base08}";
      wayland.windowManager.sway.config.colors.urgent.indicator = "#${cfg.base16.colors.base08}";
      wayland.windowManager.sway.config.colors.urgent.text = "#${cfg.base16.colors.base00}";

      wayland.windowManager.sway.config.floating.criteria = [
        {
          app_id = "^mpv$";
        }
        {
          app_id = "^pavucontrol$";
        }
        {
          app_id = "^firefox$";
          title = "^Picture-in-Picture$";
        }
        {
          app_id = "^firefox$";
          title = "^Firefox - Sharing Indicator$";
        }
      ];

      wayland.windowManager.sway.config.assigns."4" = [
        {
          class = "^Spotify$";
        }
      ];
      wayland.windowManager.sway.config.assigns."5" = [
        {
          app_id = "^thunderbird$";
        }
      ];
      wayland.windowManager.sway.config.startup = let
        services = [
          "avizo"
          "clipman"
          "kanshi"
          "waybar"
          "wlsunset"
        ];
      in
        # TODO: This should not be necessary once Sway is not racy anymore
        (concatMap
          (name: [
            {
              command = "${config.systemd.user.systemctlPath} --user reset-failed ${name}";
              always = true;
            }
            {
              command = "${config.systemd.user.systemctlPath} --user restart ${name}";
              always = true;
            }
          ])
          services)
        ++ [
          {
            command = "${pkgs.ydotool}/bin/ydotoold";
          }
          {
            command = "${config.programs.firefox.package}/bin/firefox";
          }
          {
            command = "${config.programs.thunderbird.package}/bin/thunderbird";
          }
        ];

      wayland.windowManager.sway.config.input."*" = {
        xkb_layout = config.home.keyboard.layout;
        xkb_options = defaultXkbOptions;
      };
      wayland.windowManager.sway.config.input."1:1:AT_Translated_Set_2_keyboard".xkb_options = extendDefaultXkbOptions [
        "caps:swapescape"
      ];
      wayland.windowManager.sway.config.input."1149:8264:Primax_Kensington_Eagle_Trackball".pointer_accel = "0.5";

      wayland.windowManager.sway.config.output."*".bg = "${config.xdg.userDirs.pictures}/wp fill";
      wayland.windowManager.sway.config.bindkeysToCode = true;
      wayland.windowManager.sway.config.down = "j";
      wayland.windowManager.sway.config.focus.followMouse = false;
      wayland.windowManager.sway.config.focus.mouseWarping = false;
      wayland.windowManager.sway.config.left = "h";
      wayland.windowManager.sway.config.menu = "${config.programs.wofi.package}/bin/wofi --show drun,run";
      wayland.windowManager.sway.config.modifier = "Mod4";
      wayland.windowManager.sway.config.right = "l";
      wayland.windowManager.sway.config.terminal = "${config.programs.kitty.package}/bin/kitty";
      wayland.windowManager.sway.config.up = "k";
      wayland.windowManager.sway.config.workspaceAutoBackAndForth = true;
      wayland.windowManager.sway.systemd.enable = true;
      wayland.windowManager.sway.wrapperFeatures.gtk = true;

      wayland.windowManager.sway.config.keybindings = mkOptionDefault {
        "${swayConfig.modifier}+0" = "workspace number 10";
        "${swayConfig.modifier}+b" = exec "${pkgs.bluez}/bin/bluetoothctl connect ${headphones}";
        "${swayConfig.modifier}+Ctrl+f" = exec ''${config.programs.password-store.package}/bin/gopass otp -c "$(${choosePass} 2fa)"'';
        "${swayConfig.modifier}+Ctrl+p" = exec ''${config.programs.password-store.package}/bin/gopass show -c "$(${choosePass})"'';
        "${swayConfig.modifier}+Ctrl+u" = exec ''${config.programs.password-store.package}/bin/gopass show -c "$(${choosePass})" username'';
        "${swayConfig.modifier}+Escape" = exec lockCmd;
        "${swayConfig.modifier}+g" = "floating toggle";
        "${swayConfig.modifier}+n" = exec "${config.services.mako.package}/bin/makoctl dismiss";
        "${swayConfig.modifier}+p" = exec "${config.services.clipman.package}/bin/clipman pick -t wofi";
        "${swayConfig.modifier}+q" = "kill";
        "${swayConfig.modifier}+s" = "splitv";
        "${swayConfig.modifier}+Shift+0" = "move container to workspace number 10";
        "${swayConfig.modifier}+Shift+b" = exec "${pkgs.bluez}/bin/bluetoothctl disconnect";
        "${swayConfig.modifier}+Shift+c" = "reload";
        "${swayConfig.modifier}+Shift+d" = exec "${config.systemd.user.systemctlPath} --user restart wlsunset.service";
        "${swayConfig.modifier}+Shift+Escape" = "exit";
        "${swayConfig.modifier}+Shift+f" = exec ''${config.programs.password-store.package}/bin/gopass otp -o "$(${choosePass} 2fa)" | ${pkgs.busybox}/bin/cut -d " " -f 1 | ${typeStdin}'';
        "${swayConfig.modifier}+Shift+o" = exec "${config.programs.firefox.package}/bin/firefox";
        "${swayConfig.modifier}+Shift+p" = exec ''${config.programs.password-store.package}/bin/gopass show -o -f "$(${choosePass})" | ${pkgs.busybox}/bin/head -n 1 | ${typeStdin}'';
        "${swayConfig.modifier}+Shift+s" = exec "${config.systemd.user.systemctlPath} suspend";
        "${swayConfig.modifier}+Shift+u" = exec ''${config.programs.password-store.package}/bin/gopass show -o -f "$(${choosePass})" username | ${typeStdin}'';
        "${swayConfig.modifier}+space" = exec swayConfig.menu;
        "${swayConfig.modifier}+t" = "layout stacking";
        "${swayConfig.modifier}+v" = "splith";
        "${swayConfig.modifier}+w" = "layout tabbed";
        "${swayConfig.modifier}+z" = "focus child";
        "Print+Ctrl" = exec ''${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy'';
        Print = exec ''${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "${config.xdg.userDirs.pictures}/scrot/$(${pkgs.busybox}/bin/date +%F-%T)-screenshot.png"'';
        XF86AudioLowerVolume = exec "${config.services.avizo.package}/bin/volumectl -u down";
        XF86AudioMicMute = exec "${config.services.avizo.package}/bin/volumectl -m toggle-mute";
        XF86AudioMute = exec "${config.services.avizo.package}/bin/volumectl toggle-mute";
        XF86AudioNext = exec "${pkgs.playerctl}/bin/playerctl next";
        XF86AudioPlay = exec "${pkgs.playerctl}/bin/playerctl play-pause";
        XF86AudioPrev = exec "${pkgs.playerctl}/bin/playerctl previous";
        XF86AudioRaiseVolume = exec "${config.services.avizo.package}/bin/volumectl -u up";
        XF86HomePage = exec "${config.programs.firefox.package}/bin/firefox";
        XF86MonBrightnessDown = exec "${config.services.avizo.package}/bin/lightctl down";
        XF86MonBrightnessUp = exec "${config.services.avizo.package}/bin/lightctl up";
      };

      # Based on https://github.com/Calinou/base16-godot/blob/72af0d32c6944ce1030139cdba2f25a708c37382/templates/default.mustache#L4-L38
      xdg.configFile."godot/text_editor_themes/base16.tet".text = ''
        [color_theme]

        background_color="ff${cfg.base16.colors.base00}"
        base_type_color="ff${cfg.base16.colors.base0C}"
        brace_mismatch_color="ff${cfg.base16.colors.base08}"
        breakpoint_color="30${cfg.base16.colors.base0A}"
        caret_background_color="ff${cfg.base16.colors.base05}"
        caret_color="ff${cfg.base16.colors.base05}"
        code_folding_color="ff${cfg.base16.colors.base04}"
        comment_color="ff${cfg.base16.colors.base03}"
        completion_background_color="ff${cfg.base16.colors.base01}"
        completion_existing_color="40${cfg.base16.colors.base03}"
        completion_font_color="ff${cfg.base16.colors.base04}"
        completion_scroll_color="ff${cfg.base16.colors.base04}"
        completion_selected_color="90${cfg.base16.colors.base02}"
        current_line_color="25${cfg.base16.colors.base03}"
        engine_type_color="ff${cfg.base16.colors.base0A}"
        function_color="ff${cfg.base16.colors.base0D}"
        gdscript/function_definition_color="ff${cfg.base16.colors.base0D}"
        gdscript/node_path_color="ff${cfg.base16.colors.base0F}"
        keyword_color="ff${cfg.base16.colors.base0E}"
        line_length_guideline_color="ff${cfg.base16.colors.base01}"
        line_number_color="ff${cfg.base16.colors.base03}"
        mark_color="40ff5555"
        member_variable_color="ff${cfg.base16.colors.base08}"
        number_color="ff${cfg.base16.colors.base09}"
        safe_line_number_color="ff${cfg.base16.colors.base04}"
        search_result_border_color="30${cfg.base16.colors.base0A}"
        search_result_color="30${cfg.base16.colors.base0A}"
        selection_color="90${cfg.base16.colors.base02}"
        string_color="ff${cfg.base16.colors.base0B}"
        symbol_color="ff${cfg.base16.colors.base05}"
        text_color="ff${cfg.base16.colors.base05}"
        text_selected_color="ff${cfg.base16.colors.base05}"
        word_highlighted_color="25${cfg.base16.colors.base05}"
      '';
      xdg.configFile."user-dirs.locale".text = "en_US";

      xdg.cacheHome = "${config.home.homeDirectory}/.local/cache";
      xdg.enable = true;
      xdg.userDirs.desktop = "${config.home.homeDirectory}/desktop";
      xdg.userDirs.documents = "${config.home.homeDirectory}/documents";
      xdg.userDirs.download = "${config.home.homeDirectory}/downloads";
      xdg.userDirs.music = "${config.home.homeDirectory}/music";
      xdg.userDirs.pictures = "${config.home.homeDirectory}/pictures";
      xdg.userDirs.publicShare = "${config.home.homeDirectory}/public";
      xdg.userDirs.templates = "${config.home.homeDirectory}/templates";
      xdg.userDirs.videos = "${config.home.homeDirectory}/videos";
      # TODO: Set MIME

      xresources.properties."*.background" = "#${cfg.base16.colors.base00}";
      xresources.properties."*.base00" = "#${cfg.base16.colors.base00}";
      xresources.properties."*.base01" = "#${cfg.base16.colors.base01}";
      xresources.properties."*.base02" = "#${cfg.base16.colors.base02}";
      xresources.properties."*.base03" = "#${cfg.base16.colors.base03}";
      xresources.properties."*.base04" = "#${cfg.base16.colors.base04}";
      xresources.properties."*.base05" = "#${cfg.base16.colors.base05}";
      xresources.properties."*.base06" = "#${cfg.base16.colors.base06}";
      xresources.properties."*.base07" = "#${cfg.base16.colors.base07}";
      xresources.properties."*.base08" = "#${cfg.base16.colors.base08}";
      xresources.properties."*.base09" = "#${cfg.base16.colors.base09}";
      xresources.properties."*.base0A" = "#${cfg.base16.colors.base0A}";
      xresources.properties."*.base0B" = "#${cfg.base16.colors.base0B}";
      xresources.properties."*.base0C" = "#${cfg.base16.colors.base0C}";
      xresources.properties."*.base0D" = "#${cfg.base16.colors.base0D}";
      xresources.properties."*.base0E" = "#${cfg.base16.colors.base0E}";
      xresources.properties."*.base0F" = "#${cfg.base16.colors.base0F}";
      xresources.properties."*.color0" = "#${cfg.base16.colors.base00}";
      xresources.properties."*.color1" = "#${cfg.base16.colors.base08}";
      xresources.properties."*.color2" = "#${cfg.base16.colors.base0B}";
      xresources.properties."*.color3" = "#${cfg.base16.colors.base0A}";
      xresources.properties."*.color4" = "#${cfg.base16.colors.base0D}";
      xresources.properties."*.color5" = "#${cfg.base16.colors.base0E}";
      xresources.properties."*.color6" = "#${cfg.base16.colors.base0C}";
      xresources.properties."*.color7" = "#${cfg.base16.colors.base05}";
      xresources.properties."*.color8" = "#${cfg.base16.colors.base03}";
      xresources.properties."*.color9" = "#${cfg.base16.colors.base08}";
      xresources.properties."*.color10" = "#${cfg.base16.colors.base0B}";
      xresources.properties."*.color11" = "#${cfg.base16.colors.base0A}";
      xresources.properties."*.color12" = "#${cfg.base16.colors.base0D}";
      xresources.properties."*.color13" = "#${cfg.base16.colors.base0E}";
      xresources.properties."*.color14" = "#${cfg.base16.colors.base0C}";
      xresources.properties."*.color15" = "#${cfg.base16.colors.base07}";
      xresources.properties."*.color16" = "#${cfg.base16.colors.base09}";
      xresources.properties."*.color17" = "#${cfg.base16.colors.base0F}";
      xresources.properties."*.color18" = "#${cfg.base16.colors.base01}";
      xresources.properties."*.color19" = "#${cfg.base16.colors.base02}";
      xresources.properties."*.color20" = "#${cfg.base16.colors.base04}";
      xresources.properties."*.color21" = "#${cfg.base16.colors.base06}";
      xresources.properties."*.cursorColor" = "#${cfg.base16.colors.base05}";
      xresources.properties."*.foreground" = "#${cfg.base16.colors.base05}";
      xresources.properties."ssh-askpass*background" = "#${cfg.base16.colors.base00}";
    }
    (mkIf pkgs.stdenv.hostPlatform.isLinux {
      home.packages = [
        pkgs.usbutils
      ];

      programs.kitty.settings.font_size = 15;

      services.gpg-agent.enable = true;

      xdg.userDirs.enable = true;
    })
    (mkIf (pkgs.stdenv.hostPlatform.isLinux && osConfig != null) {
      home.stateVersion = osConfig.system.stateVersion;
    })
    (mkIf pkgs.stdenv.hostPlatform.isDarwin {
      home.packages = [
        pkgs.docker
        pkgs.pkgsUnstable.lima
        pkgs.podman
        pkgs.utm
      ];

      programs.kitty.settings.font_size = 22;

      programs.zsh.sessionVariables.NOPATHHELPER = "1";

      targets.darwin.currentHostDefaults."com.apple.controlcenter".BatteryShowPercentage = true;
      targets.darwin.defaults."com.apple.desktopservices".DSDontWriteUSBStores = true;
      targets.darwin.defaults.NSGlobalDomain.AppleLocale = "en_US";
      targets.darwin.defaults.NSGlobalDomain.AppleMeasurementUnits = "Centimeters";
      targets.darwin.defaults.NSGlobalDomain.AppleMetricUnits = true;
      targets.darwin.defaults.NSGlobalDomain.AppleTemperatureUnit = "Celsius";
      targets.darwin.defaults.NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = true;
      targets.darwin.search = "DuckDuckGo";
    })
    (mkIf (pkgs.stdenv.hostPlatform.isDarwin && osConfig != null) {
      home.stateVersion = osConfig.system.nixpkgsRelease;
      home.packages = [
        osConfig.services.skhd.package
        osConfig.services.yabai.package
      ];
    })
    (mkIf osConfig.nixelium.profile.laptop.enable
      {
        home.packages =
          filter (pkg: !pkg.meta.unsupported)
          [
            rust

            pkgs.android-tools
            pkgs.avrdude
            pkgs.google-cloud-sdk
            pkgs.gqrx
            pkgs.imv
            pkgs.julia
            pkgs.kubectl
            pkgs.minikube
            pkgs.qemu
            pkgs.shellcheck
            pkgs.tcpdump
            pkgs.wit-deps
            pkgs.yubikey-manager
            pkgs.yubikey-personalization

            pkgs.pkgsUnstable.binaryen
            pkgs.pkgsUnstable.cargo-flamegraph
            pkgs.pkgsUnstable.cargo-generate
            pkgs.pkgsUnstable.cargo-watch
            pkgs.pkgsUnstable.critcmp
            pkgs.pkgsUnstable.hey
            pkgs.pkgsUnstable.nats-server
            pkgs.pkgsUnstable.natscli
            pkgs.pkgsUnstable.podman-compose
            pkgs.pkgsUnstable.redis
            pkgs.pkgsUnstable.spotify
            pkgs.pkgsUnstable.wasm-tools
            pkgs.pkgsUnstable.wasmtime
          ];

        home.sessionPath = [
          "$HOME/${config.programs.go.goBin}"
          "$HOME/.cargo/bin"
        ];

        home.shellAliases.k = "kubectl";
        home.shellAliases.ka = "kubectl apply";
        home.shellAliases.kaf = "kubectl apply -f";
        home.shellAliases.kd = "kubectl get deployments";
        home.shellAliases.mk = "minikube kubectl --";
        home.shellAliases.mka = "minikube kubectl -- apply";
        home.shellAliases.mkaf = "minikube kubectl -- apply -f";
        home.shellAliases.mkd = "minikube kubectl -- get deployments";

        programs.firefox.enable = true;
        programs.firefox.package = pkgs.firefox; # configured in overlay
        programs.firefox.profiles.main.extensions.packages = with pkgs.firefox-addons; [
          auto-tab-discard
          cookie-autodelete
          multi-account-containers
          privacy-badger
          rust-search-extension
          ublock-origin
        ];
        programs.firefox.profiles.main.search.default = "ddg";
        programs.firefox.profiles.main.search.engines.bing.metaData.hidden = true;
        programs.firefox.profiles.main.search.engines.google.metaData.alias = "@g";
        programs.firefox.profiles.main.search.engines."Nix Packages" = {
          urls = [
            {
              template = "https://search.nixos.org/packages";
              params = [
                {
                  name = "type";
                  value = "packages";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = ["@np"];
        };
        programs.firefox.profiles.main.search.engines."NixOS Wiki" = {
          urls = [{template = "https://nixos.wiki/index.php?search={searchTerms}";}];
          icon = "https://nixos.wiki/favicon.png";
          updateInterval = 24 * 60 * 60 * 1000;
          definedAliases = ["@nw"];
        };
        programs.firefox.profiles.main.search.force = true;
        programs.firefox.profiles.main.search.order = ["ddg" "google"];
        programs.firefox.profiles.main.settings."general.useragent.locale" = "en-US";
        programs.firefox.profiles.main.settings."browser.startup.homepage" = "https://duckduckgo.com";

        programs.go.enable = true;
        programs.go.package = pkgs.pkgsUnstable.go;

        programs.kitty.enable = true;
        programs.mpv.enable = true;
        programs.password-store.enable = true;
        programs.zathura.enable = true;
      })
    (mkIf (osConfig.nixelium.profile.laptop.enable && pkgs.stdenv.hostPlatform.isLinux)
      {
        fonts.fontconfig.enable = true;

        gtk.enable = true;

        home.packages = [
          pkgs.acpi
          pkgs.dex
          pkgs.espeak
          pkgs.grim
          pkgs.libnotify
          pkgs.pavucontrol
          pkgs.playerctl
          pkgs.psmisc
          pkgs.slurp
          pkgs.v4l-utils
          pkgs.wf-recorder
          pkgs.wl-clipboard
          pkgs.xdg-utils
          pkgs.ydotool
        ];

        programs.chromium.enable = true;
        programs.swaylock.enable = true;
        programs.thunderbird.enable = true;
        programs.waybar.enable = true;
        programs.wofi.enable = true;

        programs.zsh.loginExtra = ''
          if [ "$(${pkgs.busybox}/bin/tty)" = "/dev/tty1" ]; then
            exec "${config.wayland.windowManager.sway.package}/bin/sway"
          fi
        '';

        qt.enable = true;

        services.avizo.enable = true;
        services.clipman.enable = true;
        services.kanshi.enable = true;
        services.kbfs.enable = true; # TODO: Remove
        services.keybase.enable = true; # TODO: Remove
        services.mako.enable = true;
        services.playerctld.enable = true;
        services.swayidle.enable = true;
        services.wlsunset.enable = true;

        wayland.windowManager.sway.enable = true;
        wayland.windowManager.sway.swaynag.enable = true;
      })
  ];
}
