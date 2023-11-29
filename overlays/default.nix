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

  unstable = final: prev: let
    pkgsUnstable = nixpkgs-unstable.legacyPackages.${final.stdenv.hostPlatform.system};
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
      bash-language-server
      chromium
      eza
      fira-code-nerdfont
      firefox
      firefox-bin
      firefox-unwrapped
      kitty
      lima
      lima-bin
      mullvad
      mullvad-vpn
      neovim
      neovim-unwrapped
      rust-analyzer
      skhd
      thunderbird
      tinygo
      tree-sitter
      tree-sitter-grammars
      utm
      vimPlugins
      vimUtils
      wrapFirefox
      wrapNeovim
      yabai
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
