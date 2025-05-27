inputs @ {
  fenix,
  firefox-addons,
  neovim,
  nixlib,
  nixpkgs-neovim,
  nixpkgs-unstable,
  ...
}:
with nixlib.lib; let
  importNixpkgs = nixpkgs: final: prev:
    import nixpkgs {
      inherit
        (final.stdenv.hostPlatform)
        system
        ;

      inherit
        (final)
        config
        ;
    };

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

  grml-zsh-config = final: prev: {
    grml-zsh-config = prev.grml-zsh-config.overrideAttrs ({nativeBuildInputs ? [], ...}: {
      # https://github.com/grml/grml-etc-core/pull/202
      version = "0.19.19-patched";
      src = final.fetchFromGitHub {
        owner = "grml";
        repo = "grml-etc-core";
        rev = "765cf43a3f865f62bbd1ea6ef3a36889cd9222c5";
        sha256 = "sha256-okPDIqbXI56Z7WTaLszdBft2pSoYSdMfrgn35SoSMWY=";
      };

      # https://github.com/NixOS/nixpkgs/pull/411436
      nativeBuildInputs =
        nativeBuildInputs
        ++ [
          final.asciidoctor
        ];
    });
  };

  gopass = final: prev: {
    gopass = prev.pkgsUnstable.gopass.override {
      passAlias = true;
    };
  };

  neovim' = final: prev: {
    neovim = final.pkgsNeovim.wrapNeovim final.pkgsNeovim.neovim-unwrapped (import ./neovim inputs final);
  };

  rust-analyzer = final: prev: {
    inherit
      (fenix.packages.${prev.stdenv.hostPlatform.system})
      rust-analyzer
      ;
  };

  pkgsUnstable = final: prev: {
    pkgsUnstable = importNixpkgs nixpkgs-unstable final prev;
  };

  pkgsNeovim = final: prev: {
    pkgsNeovim = importNixpkgs nixpkgs-neovim final prev;
  };
in {
  inherit
    firefox
    gopass
    grml-zsh-config
    images
    infrastructure
    install
    pkgsNeovim
    pkgsUnstable
    quake3
    rust-analyzer
    scripts
    ;

  neovim = neovim';
  neovim-nightly = neovim.overlay;

  firefox-addons = firefox-addons';

  fenix = fenix.overlays.default;

  default = composeManyExtensions [
    pkgsNeovim
    pkgsUnstable

    fenix.overlays.default
    rust-analyzer

    firefox
    firefox-addons'
    gopass
    grml-zsh-config
    neovim'
    quake3

    infrastructure
    install
    scripts

    images
  ];
}
