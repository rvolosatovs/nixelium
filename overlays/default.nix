inputs @ {
  fenix,
  neovim,
  nixlib,
  nixpkgs,
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
      final.pkgsUnstable.wrapFirefox final.pkgsUnstable.firefox-unwrapped
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
    gopass = prev.pkgsUnstable.gopass.override {
      passAlias = true;
    };
  };

  neovim' = final: prev: {
    neovim = final.pkgsUnstable.wrapNeovim final.pkgsUnstable.neovim-unwrapped (import ./neovim inputs final);
  };

  rust-analyzer = final: prev: {
    inherit
      (fenix.packages.${prev.stdenv.hostPlatform.system})
      rust-analyzer
      ;
  };

  unstable = final: prev: {
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
  };

  master = final: prev: {
    pkgsMaster = import nixpkgs {
      inherit
        (final.stdenv.hostPlatform)
        system
        ;

      inherit
        (final)
        config
        ;
    };
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
    master

    fenix.overlays.default
    rust-analyzer

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
