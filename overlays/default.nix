inputs@{
  claude-code-nix,
  codex-cli-nix,
  fenix,
  firefox-addons,
  nixlib,
  nixpkgs-kitty,
  nixpkgs-unstable,
  slack-darwin-aarch64,
  spotify-darwin-aarch64,
  ...
}:
with nixlib.lib;
let
  importNixpkgs =
    nixpkgs: overlays: final: prev:
    import nixpkgs {
      inherit (final.stdenv.hostPlatform) system;

      inherit (final) config;
      inherit overlays;
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
    firefox = final.wrapFirefox final.firefox-unwrapped {
      ## Documentation available at:
      ## https://github.com/mozilla/policy-templates

      extraPolicies.CaptivePortal = true;
      extraPolicies.DisableFirefoxAccounts = true;
      extraPolicies.DisableFirefoxStudies = true;
      extraPolicies.DisablePocket = true;
      extraPolicies.DisableTelemetry = true;
      extraPolicies.ExtensionSettings = { };
      extraPolicies.FirefoxHome.Pocket = false;
      extraPolicies.FirefoxHome.Snippets = false;
      extraPolicies.UserMessaging.ExtensionRecommendations = false;
      extraPolicies.UserMessaging.SkipOnboarding = true;
    };
  };

  gopass = final: prev: { gopass = prev.pkgsUnstable.gopass.override { passAlias = true; }; };

  neovim' = final: prev: {
    neovim = final.wrapNeovim final.neovim-unwrapped (import ./neovim inputs final);
  };

  slack =
    final: prev:
    optionalAttrs (prev.stdenv.hostPlatform.isDarwin && prev.stdenv.hostPlatform.isAarch64) {
      slack = prev.slack.overrideAttrs (_: {
        version = "unstable";
        src = prev.runCommand "Slack-macOS.dmg" { } "ln -s ${slack-darwin-aarch64} $out";
      });
    };

  spotify =
    final: prev:
    optionalAttrs (prev.stdenv.hostPlatform.isDarwin && prev.stdenv.hostPlatform.isAarch64) {
      spotify = prev.spotify.overrideAttrs (_: {
        version = "unstable";
        src = prev.runCommand "SpotifyARM64.dmg" { } "ln -s ${spotify-darwin-aarch64} $out";
      });
    };

  overlays = [
    slack
    spotify
  ];

  pkgsUnstable = final: prev: {
    pkgsUnstable = importNixpkgs nixpkgs-unstable overlays final prev;
  };

  unstable = final: prev: {
    lima = prev.pkgsUnstable.lima;
    nerdctl = prev.pkgsUnstable.nerdctl;

    # TODO: Remove
    kitty =
      let
        pkgs = importNixpkgs nixpkgs-kitty overlays final prev;
      in
      if versionOlder pkgs.kitty.version prev.kitty.version then
        warn "nixpkgs provides kitty ${prev.kitty.version}, ignoring override" prev.kitty
      else
        pkgs.kitty;
  };
in
{
  inherit
    firefox
    gopass
    images
    infrastructure
    install
    pkgsUnstable
    quake3
    scripts
    unstable
    ;

  neovim = neovim';

  firefox-addons = firefox-addons';

  fenix = fenix.overlays.default;

  default = composeManyExtensions [
    pkgsUnstable

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

    unstable

    claude-code-nix.overlays.default
    codex-cli-nix.overlays.default
  ];
}
