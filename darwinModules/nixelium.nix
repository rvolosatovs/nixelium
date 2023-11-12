{
  self,
  home-manager,
  homebrew-cask,
  homebrew-core,
  nix-homebrew,
  nixlib,
  nixpkgs-darwin,
  ...
}: {
  config,
  pkgs,
  ...
}:
with nixlib.lib; let
  username = "rvolosatovs";
in {
  imports = [
    home-manager.darwinModules.home-manager
    nix-homebrew.darwinModules.nix-homebrew
  ];
  options.nixelium.profile.laptop.enable = mkEnableOption "laptop profile";
  config = {
    environment.pathsToLink = [
      "/share/bash"
      "/share/bash-completion"
      "/share/zsh"
    ];

    fonts.fonts = [
      pkgs.fira
      pkgs.fira-code
      pkgs.fira-code-nerdfont
      pkgs.fira-code-symbols
      pkgs.fira-mono
      pkgs.font-awesome
      pkgs.roboto-slab
    ];
    fonts.fontDir.enable = true;

    homebrew.casks = [
      "chromium"
      "firefox"
      "notunes"
    ];
    homebrew.enable = true;

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.${username} = self.homeModules.default;

    networking.dns = [
      "2620:fe::fe"
      "2620:fe::9"
      "9.9.9.9"
      "149.112.112.112"
    ];

    nix.configureBuildUsers = true;
    nix.extraOptions = concatStringsSep "\n" [
      "keep-outputs = true"
      "keep-derivations = true"
      "experimental-features = nix-command flakes"
    ];
    nix.gc.automatic = true;
    nix.registry.nixpkgs.flake = nixpkgs-darwin;
    nix.registry.nixpkgs.from.id = "nixpkgs";
    nix.registry.nixpkgs.from.type = "indirect";
    nix.settings.allowed-users = with config.users; [
      "@admin"
      users.${username}.name
    ];
    nix.settings.auto-optimise-store = true;
    nix.settings.require-sigs = true;
    nix.settings.substituters = [
      "https://cache.nixos.org"
      "https://rvolosatovs.cachix.org"
      "https://wasmcloud.cachix.org"
      "https://nix-community.cachix.org"
    ];
    nix.settings.trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "rvolosatovs.cachix.org-1:eRYUO4OXTSmpDFWu4wX3/X08MsP01baqGKi9GsoAmQ8="
      "wasmcloud.cachix.org-1:9gRBzsKh+x2HbVVspreFg/6iFRiD4aOcUQfXVDl3hiM="
    ];
    nix.settings.trusted-users = with config.users; [
      "@admin"
      users.${username}.name
    ];

    nixpkgs.config = import "${self}/nixpkgs/config.nix";
    nixpkgs.overlays = [
      self.overlays.default
    ];

    nix-homebrew.enable = true;
    nix-homebrew.enableRosetta = true;
    nix-homebrew.mutableTaps = false;
    nix-homebrew.taps."homebrew/homebrew-cask" = homebrew-cask;
    nix-homebrew.taps."homebrew/homebrew-core" = homebrew-core;
    nix-homebrew.user = username;

    programs.bash.enable = true;
    programs.bash.enableCompletion = true;

    programs.gnupg.agent.enable = true;
    programs.gnupg.agent.enableSSHSupport = true;

    programs.zsh.enable = true;
    programs.zsh.enableBashCompletion = true;
    programs.zsh.interactiveShellInit = ''
      setopt INTERACTIVE_COMMENTS NO_NOMATCH
    '';

    security.pam.enableSudoTouchIdAuth = true;

    services.nix-daemon.enable = true;

    services.tailscale.enable = true;

    services.yabai.enable = true;
    services.yabai.enableScriptingAddition = true;

    system.stateVersion = 4;

    users.knownGroups = with config.users; [
      groups.nix.name
    ];
    users.knownUsers = with config.users; [
      users.nix.name
    ];

    users.groups.nix.gid = 542;
    users.groups.nix.members = ["nix"];

    users.users.nix.createHome = true;
    users.users.nix.gid = config.users.groups.nix.gid;
    users.users.nix.home = "/Users/nix";
    users.users.nix.uid = config.users.groups.nix.gid;

    users.users.${username} = {
      uid = mkDefault 501;
      name = username;
      home = "/Users/${username}";
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKEC3hGlw5tDKcfbvTd+IdZxGSdux1i/AIK3mzx4bZuX"
      ];
    };
  };
}
