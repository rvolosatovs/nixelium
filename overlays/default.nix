inputs @ {
  fenix,
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

  neovim = final: prev: {
    neovim = final.wrapNeovim final.neovim-unwrapped (import ./neovim inputs final);
  };

  unstable = final: prev: let
    pkgsUnstable = nixpkgs-unstable.legacyPackages.${final.stdenv.hostPlatform.system};
  in {
    inherit
      pkgsUnstable
      ;

    inherit
      (pkgsUnstable)
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
      skhd
      tinygo
      utm
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
    neovim
    quake3
    scripts
    unstable
    ;

  firefox-addons = firefox-addons';

  fenix = fenix.overlays.default;

  default = composeManyExtensions [
    unstable

    fenix.overlays.default

    firefox
    firefox-addons'
    gopass
    neovim
    quake3

    infrastructure
    install
    scripts

    images
  ];
}
