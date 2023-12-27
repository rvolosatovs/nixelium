inputs @ {
  fenix,
  neovim,
  nixlib,
  nixpkgs-unstable,
  firefox-addons,
  ...
}:
with nixlib.lib; let
  images = import ./images.nix inputs;
  infrastructure = import ./infrastructure.nix inputs;
  install = import ./install.nix inputs;
  quake3 = import ./quake3.nix inputs;
  scripts = import ./scripts.nix inputs;

  firefox-addons' = final: prev: {
    firefox-addons = firefox-addons.packages.${final.stdenv.hostPlatform.system};
  };

  firefox = final: prev: {
    firefox =
      final.wrapFirefox final.firefox-unwrapped
      {
        ## Documentation available at:
        ## https://github.com/mozilla/policy-templates

        extraPolicies.CaptivePortal = true;
        extraPolicies.DisableFirefoxAccounts = true;
        extraPolicies.DisableFirefoxStudies = true;
        extraPolicies.DisablePocket = true;
        extraPolicies.DisableTelemetry = true;
        extraPolicies.ExtensionSettings = {};
        extraPolicies.FirefoxHome.Pocket = false;
        extraPolicies.FirefoxHome.Snippets = false;
        extraPolicies.UserMessaging.ExtensionRecommendations = false;
        extraPolicies.UserMessaging.SkipOnboarding = true;
      };
  };

  gopass = final: prev: {
    gopass = prev.gopass.override {
      passAlias = true;
    };
  };

  neovim' = final: prev: {
    neovim = final.wrapNeovim neovim.packages.${final.stdenv.hostPlatform.system}.neovim (import ./neovim inputs final);
  };

  rust-analyzer = final: prev: {
    inherit
      (fenix.packages.${prev.stdenv.hostPlatform.system})
      rust-analyzer
      ;
  };

  unstable = final: prev: let
    pkgsUnstable = import nixpkgs-unstable {
      inherit
        (final.stdenv.hostPlatform)
        system
        ;

      inherit
        (final)
        config
        ;
    };
    ## based on https://github.com/NixOS/nix/issues/3920#issuecomment-1168041777
    #nixpkgs-unstable-patched-src = final.applyPatches {
    #  name = "nixpkgs-patched-${nixpkgs-unstable.shortRev}";
    #  src = nixpkgs-unstable;
    #  patches = [
    #    (
    #      final.fetchpatch {
    #        url = "https://github.com/NixOS/nixpkgs/pull/268485.patch";
    #        sha256 = "sha256-+DVqJXixL5D850lQfUtKJE0+diL6nGulUhn3UV1DqG8=";
    #      }
    #    )
    #  ];
    #};
    #nixpkgs-unstable-patched = fix (self:
    #  (import "${nixpkgs-unstable-patched-src}/flake.nix").outputs {
    #    inherit self;
    #  });
    #pkgsUnstablePatched = nixpkgs-unstable-patched.legacyPackages.${final.stdenv.hostPlatform.system};
  in {
    inherit
      pkgsUnstable
      ;

    inherit
      (pkgsUnstable)
      act
      alacritty
      alejandra
      arduino
      asciinema
      bash-language-server
      bat
      bat-extras
      borgbackup
      brave
      cachix
      cargo-edit
      cargo-tarpaulin
      cargo-watch
      chromium
      cockroachdb
      deadcode
      deno
      direnv
      drive
      du-dust
      echoip
      elmPackages
      eza
      fd
      fira
      fira-code
      fira-code-nerdfont
      firefox
      firefox-bin
      firefox-unwrapped
      firmwareLinuxNonfree
      fzf
      go-2fa
      go-sct
      go-tools
      godef
      godot
      gofumpt
      gopass
      gopls
      gotools
      grim
      grml-zsh-config
      hyperfine
      imv
      ioquake3
      jackett
      kanshi
      kbfs
      keybase
      keybase-gui
      kitty
      lidarr
      lima
      lima-bin
      linux_lqx
      linux_zen
      linuxPackages_latest
      linuxPackages_lqx
      linuxPackages_zen
      lutris
      minicom
      miniflux
      mkvtoolnix
      motion
      mpv
      mullvad
      mullvad-vpn
      neovim
      neovim-unwrapped
      nerdfonts
      nix-du
      nixfmt
      nixpkgs-fmt
      pavucontrol
      qmk
      quake3e
      quake3hires
      quake3pointrelease
      quake3wrapper
      radarr
      rclone
      redis
      redshift
      redshift-wlr
      restic
      ripgrep
      rnix-lsp
      rofi
      rust-analyzer
      sd
      sidequest
      skhd
      skim
      slurp
      sonarr
      steam
      stt
      sumneko-lua-language-server
      syncthing
      syncthing-cli
      syncthing-tray
      thunderbird
      tinygo
      tokei
      tree-sitter
      tree-sitter-grammars
      ungoogled-chromium
      utm
      vim
      vimPlugins
      vimUtils
      wasm-pack
      wasmtime
      weechat
      wf-recorder
      wl-clipboard
      wlsunset
      wofi
      wrapFirefox
      wrapNeovim
      yabai
      yarn
      ydotool
      youtube-dl
      zig
      ;
  };
in {
  inherit
    firefox
    gopass
    images
    infrastructure
    install
    quake3
    rust-analyzer
    scripts
    unstable
    ;

  neovim = neovim';
  neovim-nightly = neovim.overlay;

  firefox-addons = firefox-addons';

  fenix = fenix.overlays.default;

  default = composeManyExtensions [
    unstable

    fenix.overlays.default

    firefox
    firefox-addons'
    gopass
    neovim'
    quake3

    infrastructure
    install
    scripts

    images
  ];
}
