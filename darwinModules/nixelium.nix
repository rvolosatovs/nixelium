{
  self,
  home-manager,
  nixlib,
  nixpkgs-darwin,
  nixpkgs-firefox-darwin,
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
  ];

  options.nixelium.profile.laptop.enable = mkEnableOption "laptop profile";

  config = mkMerge [
    {
      environment.pathsToLink = [
        "/share/bash"
        "/share/bash-completion"
        "/share/zsh"
      ];
      environment.shellInit = "eval $(brew shellenv)";
      environment.systemPath = [
        "/opt/homebrew/bin"
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

      homebrew.brews = [
        {
          name = "felixkratz/formulae/borders";
          start_service = true;
          restart_service = "changed";
        }
      ];
      homebrew.casks = [
        "chromium"
        "mac-mouse-fix"
        "maccy"
        "notunes"
        "slack"
        "zoom"
      ];
      homebrew.caskArgs.require_sha = true;
      homebrew.enable = true;

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      home-manager.users.${username} = self.homeModules.default;
      home-manager.users.root = self.homeModules.default;

      networking.dns = [
        "2620:fe::fe"
        "2620:fe::9"
        "9.9.9.9"
        "149.112.112.112"
      ];

      nix.configureBuildUsers = true;
      nix.distributedBuilds = true;
      nix.extraOptions = concatStringsSep "\n" [
        "builders-use-substitutes = true"
        "experimental-features = nix-command flakes"
        "keep-derivations = true"
        "keep-outputs = true"
      ];
      nix.gc.automatic = true;
      nix.linux-builder.enable = mkDefault true;
      nix.linux-builder.maxJobs = mkDefault 8;
      nix.linux-builder.package = mkDefault pkgs.pkgsUnstable.darwin.linux-builder; # TODO: Remove in 23.11
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

        nixpkgs-firefox-darwin.overlay
      ];

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

      services.skhd.enable = true;
      services.skhd.skhdConfig = ''
        # TODO: Reenable once it actually works ???
        #ctrl - 1                : ${config.services.yabai.package}/bin/yabai -m space --focus 1
        #ctrl - 2                : ${config.services.yabai.package}/bin/yabai -m space --focus 2
        #ctrl - 3                : ${config.services.yabai.package}/bin/yabai -m space --focus 3
        #ctrl - 4                : ${config.services.yabai.package}/bin/yabai -m space --focus 4
        #ctrl - 5                : ${config.services.yabai.package}/bin/yabai -m space --focus 5
        ctrl - 6                : ${config.services.yabai.package}/bin/yabai -m space --focus 6
        ctrl - 7                : ${config.services.yabai.package}/bin/yabai -m space --focus 7
        ctrl - 8                : ${config.services.yabai.package}/bin/yabai -m space --focus 8
        ctrl - 9                : ${config.services.yabai.package}/bin/yabai -m space --focus 9
        ctrl - 0                : ${config.services.yabai.package}/bin/yabai -m space --focus 10

        ctrl + shift - 1        : ${config.services.yabai.package}/bin/yabai -m window --space 1
        ctrl + shift - 2        : ${config.services.yabai.package}/bin/yabai -m window --space 2
        ctrl + shift - 3        : ${config.services.yabai.package}/bin/yabai -m window --space 3
        ctrl + shift - 4        : ${config.services.yabai.package}/bin/yabai -m window --space 4
        ctrl + shift - 5        : ${config.services.yabai.package}/bin/yabai -m window --space 5
        ctrl + shift - 6        : ${config.services.yabai.package}/bin/yabai -m window --space 6
        ctrl + shift - 7        : ${config.services.yabai.package}/bin/yabai -m window --space 7
        ctrl + shift - 8        : ${config.services.yabai.package}/bin/yabai -m window --space 8
        ctrl + shift - 9        : ${config.services.yabai.package}/bin/yabai -m window --space 9
        ctrl + shift - 0        : ${config.services.yabai.package}/bin/yabai -m window --space 10

        cmd + ctrl - g          : ${config.services.yabai.package}/bin/yabai -m window --toggle float
        cmd + ctrl - e          : ${config.services.yabai.package}/bin/yabai -m window --toggle split
        cmd + ctrl - w          : ${config.services.yabai.package}/bin/yabai -m window --toggle zoom-parent

        cmd + ctrl - h          : ${config.services.yabai.package}/bin/yabai -m window --focus west
        cmd + ctrl - j          : ${config.services.yabai.package}/bin/yabai -m window --focus south
        cmd + ctrl - k          : ${config.services.yabai.package}/bin/yabai -m window --focus north
        cmd + ctrl - l          : ${config.services.yabai.package}/bin/yabai -m window --focus east

        cmd + ctrl + shift - h  : ${config.services.yabai.package}/bin/yabai -m window --warp west
        cmd + ctrl + shift - j  : ${config.services.yabai.package}/bin/yabai -m window --warp south
        cmd + ctrl + shift - k  : ${config.services.yabai.package}/bin/yabai -m window --warp north
        cmd + ctrl + shift - l  : ${config.services.yabai.package}/bin/yabai -m window --warp east

        cmd - return            : ${config.home-manager.users.${username}.programs.kitty.package}/Applications/kitty.app/Contents/MacOS/kitty --single-instance -d ~
        cmd + shift - o         : ${config.home-manager.users.${username}.programs.firefox.package}/Applications/firefox.app/Contents/MacOS/firefox
      '';

      services.yabai.config.auto_balance = "on";
      services.yabai.config.focus_follows_mouse = "autofocus";
      services.yabai.config.layout = "bsp";
      services.yabai.config.mouse_modifier = "alt";
      services.yabai.config.split_type = "vertical";
      services.yabai.config.window_gap = 5;
      services.yabai.config.window_topmost = "on";
      services.yabai.enable = true;
      services.yabai.enableScriptingAddition = true;
      services.yabai.extraConfig = ''
        ${config.services.yabai.package}/bin/yabai -m rule --add app="^System Information$" manage=off
        ${config.services.yabai.package}/bin/yabai -m rule --add app="^System Settings$" manage=off

        ${config.services.yabai.package}/bin/yabai -m rule --add title="^Preferences$" manage=off
        ${config.services.yabai.package}/bin/yabai -m rule --add title="^Settings$" manage=off
      '';

      system.defaults.dock.autohide = true;
      system.defaults.finder.AppleShowAllExtensions = true;
      system.defaults.finder.AppleShowAllFiles = true;
      system.keyboard.enableKeyMapping = true;
      system.keyboard.remapCapsLockToEscape = true;
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
      users.users.nix.openssh.authorizedKeys.keys = config.users.users.${username}.openssh.authorizedKeys.keys;
      users.users.nix.shell = pkgs.bashInteractive;
      users.users.nix.uid = config.users.groups.nix.gid;

      users.users.root.home = "/var/root";
      users.users.root.openssh.authorizedKeys.keys = config.users.users.${username}.openssh.authorizedKeys.keys;
      users.users.root.shell = pkgs.zsh;
      users.users.root.uid = 0;

      users.users.${username} = {
        home = "/Users/${username}";
        name = username;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKEC3hGlw5tDKcfbvTd+IdZxGSdux1i/AIK3mzx4bZuX"
        ];
        shell = pkgs.zsh;
        uid = mkDefault 501;
      };
    }

    (mkIf self.nixosConfigurations.osmium.config.nixelium.build.enable {
      nix.buildMachines = [
        {
          hostName = "osmium.ghost-ordinal.ts.net";
          maxJobs = 8;
          protocol = "ssh-ng";
          sshKey = "${config.users.users.root.home}/.ssh/id_osmium_nix";
          sshUser = "nix";
          supportedFeatures = [
            "benchmark"
            "big-parallel"
            "kvm"
            "nixos-test"
          ];
          systems = [
            "aarch64-linux"
            "x86_64-linux"
          ];
        }
      ];
    })
  ];
}
