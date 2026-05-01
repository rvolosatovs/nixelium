{
  self,
  determinate,
  home-manager,
  nixify,
  nixlib,
  nixpkgs-darwin,
  nixpkgs-nixos,
  nixpkgs-unstable,
  wit-deps,
  yabai-status,
  ...
}:
{ config, pkgs, ... }:
with nixlib.lib;
let
  substituters = [
    "https://rvolosatovs.cachix.org"
    "https://nixify.cachix.org"
    "https://cache.nixos.org"
    "https://wasmcloud.cachix.org"
    "https://bytecodealliance.cachix.org"
    "https://crane.cachix.org"
    "https://nix-community.cachix.org"
  ];

  username = "rvolosatovs";

  gopass = "${config.home-manager.users.${username}.programs.password-store.package}/bin/gopass";
  choose = "${pkgs.choose-gui}/bin/choose";

  typeStdin = pkgs.writeShellScript "nixelium-type-stdin" ''
    NIXELIUM_PASS_TEXT=$(cat)
    export NIXELIUM_PASS_TEXT
    /usr/bin/osascript -e 'tell application "System Events" to keystroke (system attribute "NIXELIUM_PASS_TEXT")'
  '';
in
{
  imports = [
    determinate.darwinModules.default
    home-manager.darwinModules.home-manager
    yabai-status.darwinModules.default
  ];

  options.nixelium.profile.dev.enable = mkEnableOption "dev profile";
  options.nixelium.profile.laptop.enable = mkEnableOption "laptop profile";
  options.nixelium.profile.vm.enable = mkEnableOption "VM profile";
  options.nixelium.system.isVirtual = mkEnableOption "system virtualization";

  config = mkMerge [
    {
      determinateNix.enable = true;

      environment.enableAllTerminfo = true;
      environment.pathsToLink = [
        "/share/bash"
        "/share/bash-completion"
        "/share/qemu"
        "/share/zsh"
      ];
      environment.shellInit = "eval $(brew shellenv)";
      environment.systemPath = [ "/opt/homebrew/bin" ];

      fonts.packages = [
        pkgs.fira
        pkgs.fira-code
        pkgs.fira-code-symbols
        pkgs.fira-mono
        pkgs.font-awesome
        pkgs.nerd-fonts.fira-code
        pkgs.roboto-slab
      ];

      homebrew.brews = [
        "juliaup"
      ];
      homebrew.casks = [
        {
          name = "chromium";
          args.require_sha = false;
        }
        "firefox" # TODO: switch to nixpkgs
        "mac-mouse-fix"
        "notunes"
      ];
      homebrew.caskArgs.require_sha = true;
      homebrew.enable = true;

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      home-manager.users.${username} = self.homeModules.default;
      home-manager.users.root = self.homeModules.default;

      determinateNix.distributedBuilds = true;
      determinateNix.customSettings.allowed-users = with config.users; [
        "@admin"
        users.${username}.name
      ];
      determinateNix.customSettings.builders-use-substitutes = true;
      determinateNix.customSettings.keep-derivations = true;
      determinateNix.customSettings.keep-outputs = true;
      determinateNix.customSettings.require-sigs = true;
      determinateNix.customSettings.substituters = substituters;
      determinateNix.customSettings.use-case-hack = false;
      determinateNix.customSettings.trusted-public-keys = [
        "rvolosatovs.cachix.org-1:eRYUO4OXTSmpDFWu4wX3/X08MsP01baqGKi9GsoAmQ8="
        "nixify.cachix.org-1:95SiUQuf8Ij0hwDweALJsLtnMyv/otZamWNRp1Q1pXw="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "wasmcloud.cachix.org-1:9gRBzsKh+x2HbVVspreFg/6iFRiD4aOcUQfXVDl3hiM="
        "bytecodealliance.cachix.org-1:0SBgh//n2n0heh0sDFhTm+ZKBRy2sInakzFGfzN531Y="
        "crane.cachix.org-1:8Scfpmn9w+hGdXH/Q9tTLiYAE/2dnJYRJP7kl80GuRk="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      determinateNix.customSettings.trusted-substituters = substituters;
      determinateNix.customSettings.trusted-users = with config.users; [
        "@admin"
        users.${username}.name
      ];

      determinateNix.registry.nixelium.flake = self;
      determinateNix.registry.nixelium.from.id = "nixelium";
      determinateNix.registry.nixelium.from.type = "indirect";

      determinateNix.registry.nixify.flake = nixify;
      determinateNix.registry.nixify.from.id = "nixify";
      determinateNix.registry.nixify.from.type = "indirect";

      determinateNix.registry.nixlib.flake = nixlib;
      determinateNix.registry.nixlib.from.id = "nixlib";
      determinateNix.registry.nixlib.from.type = "indirect";

      determinateNix.registry.nixpkgs.flake = nixpkgs-darwin;
      determinateNix.registry.nixpkgs.from.id = "nixpkgs";
      determinateNix.registry.nixpkgs.from.type = "indirect";

      determinateNix.registry.nixpkgs-nixos.flake = nixpkgs-nixos;
      determinateNix.registry.nixpkgs-nixos.from.id = "nixpkgs-nixos";
      determinateNix.registry.nixpkgs-nixos.from.type = "indirect";

      determinateNix.registry.nixpkgs-unstable.flake = nixpkgs-unstable;
      determinateNix.registry.nixpkgs-unstable.from.id = "nixpkgs-unstable";
      determinateNix.registry.nixpkgs-unstable.from.type = "indirect";

      ids.gids.nixbld = 30000;

      networking.dns = [
        "2620:fe::fe"
        "2620:fe::9"
        "9.9.9.9"
        "149.112.112.112"
      ];

      nix.extraOptions = concatStringsSep "\n" (
        optional (!config.determinateNix.enable) "experimental-features = nix-command flakes"
      );
      nix.gc.automatic = !config.determinateNix.enable && !config.nixelium.system.isVirtual;
      nix.optimise.automatic = !config.determinateNix.enable && !config.nixelium.system.isVirtual;

      nixpkgs.config = import "${self}/nixpkgs/config.nix";
      nixpkgs.overlays = [
        self.overlays.default

        wit-deps.overlays.default
      ];

      programs.bash.completion.enable = true;
      programs.bash.enable = true;

      programs.gnupg.agent.enable = true;
      programs.gnupg.agent.enableSSHSupport = true;

      programs.zsh.enable = true;
      programs.zsh.enableBashCompletion = true;
      programs.zsh.interactiveShellInit = ''
        setopt INTERACTIVE_COMMENTS NO_NOMATCH
      '';
      programs.zsh.histSize = 50000;

      security.pam.services.sudo_local.touchIdAuth = true;

      services.jankyborders.enable = true;

      services.openssh.enable = true;

      services.skhd.enable = true;
      services.skhd.skhdConfig = ''
        # NOTE: First six are handled by MacOS, set the config manually
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
        cmd + ctrl - w          : ${config.services.yabai.package}/bin/yabai -m window --toggle zoom-fullscreen

        cmd + ctrl - h          : ${config.services.yabai.package}/bin/yabai -m window --focus west
        cmd + ctrl - j          : ${config.services.yabai.package}/bin/yabai -m window --focus south
        cmd + ctrl - k          : ${config.services.yabai.package}/bin/yabai -m window --focus north
        cmd + ctrl - l          : ${config.services.yabai.package}/bin/yabai -m window --focus east

        cmd + ctrl + shift - h  : ${config.services.yabai.package}/bin/yabai -m window --warp west
        cmd + ctrl + shift - j  : ${config.services.yabai.package}/bin/yabai -m window --warp south
        cmd + ctrl + shift - k  : ${config.services.yabai.package}/bin/yabai -m window --warp north
        cmd + ctrl + shift - l  : ${config.services.yabai.package}/bin/yabai -m window --warp east

        cmd - return            : open -n ${
          config.home-manager.users.${username}.programs.kitty.package
        }/Applications/kitty.app --args --single-instance -d ~
        # TODO: switch to nixpkgs
        cmd + shift - o         : open -n /Applications/Firefox.app

        cmd + ctrl - p          : ${gopass} show -c "$(${gopass} list --flat | ${choose})"
        cmd + ctrl - u          : ${gopass} show -c "$(${gopass} list --flat | ${choose})" username
        cmd + ctrl - o          : ${gopass} otp  -c "$(${gopass} list --flat 2fa | ${choose})"
        cmd + shift - p         : ${gopass} show -o -f "$(${gopass} list --flat | ${choose})" | /usr/bin/head -n 1 | ${typeStdin}
        cmd + shift - u         : ${gopass} show -o -f "$(${gopass} list --flat | ${choose})" username | ${typeStdin}
        cmd + shift - f         : ${gopass} otp  -o    "$(${gopass} list --flat 2fa | ${choose})" | /usr/bin/cut -d ' ' -f 1 | ${typeStdin}
      '';
      services.skhd.package = pkgs.pkgsUnstable.skhd;

      services.tailscale.enable = true;

      services.yabai.config.auto_balance = "on";
      services.yabai.config.layout = "bsp";
      services.yabai.config.mouse_modifier = "alt";
      services.yabai.config.split_type = "vertical";
      services.yabai.config.window_gap = 5;
      services.yabai.config.window_topmost = "on";
      services.yabai.enable = true;
      services.yabai.enableScriptingAddition = true;
      services.yabai.extraConfig = ''
        ${config.services.yabai.package}/bin/yabai -m rule --add app="^(Calculator|Software Update|Dictionary|VLC|System Preferences|System Settings|Photo Booth|Archive Utility|Python|LibreOffice|App Store|Steam|Alfred|Activity Monitor)$" manage=off
        ${config.services.yabai.package}/bin/yabai -m rule --add label="Finder" app="^Finder$" title="(Co(py|nnect)|Move|Info|Pref)" manage=off
        ${config.services.yabai.package}/bin/yabai -m rule --add label="Safari" app="^Safari$" title="^(General|(Tab|Password|Website|Extension)s|AutoFill|Se(arch|curity)|Privacy|Advance)$" manage=off
        ${config.services.yabai.package}/bin/yabai -m rule --add label="About This Mac" app="System Information" title="About This Mac" manage=off
        ${config.services.yabai.package}/bin/yabai -m rule --add label="Select file to save to" app="^Inkscape$" title="Select file to save to" manage=off

        borders style=square
      '';
      services.yabai.package = pkgs.pkgsUnstable.yabai;

      services.yabai-status.enable = true;

      system.activationScripts.postActivation.text = ''
        ${config.services.yabai.package}/bin/yabai --load-sa || true
      '';

      system.defaults.CustomUserPreferences."com.apple.Music".AutoPlayOnConnect = false;
      system.defaults.dock.autohide = true;
      system.defaults.dock.autohide-delay = 0.0;
      system.defaults.dock.show-recents = false;
      system.defaults.finder.AppleShowAllExtensions = true;
      system.defaults.finder.AppleShowAllFiles = true;
      system.defaults.dock.wvous-br-corner = 12; # Notification Center
      system.defaults.dock.wvous-tr-corner = 2; # Mission Control
      system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;
      system.defaults.WindowManager.EnableStandardClickToShowDesktop = false;
      system.keyboard.enableKeyMapping = true;
      system.keyboard.remapCapsLockToEscape = true;
      system.primaryUser = username;
      system.stateVersion = 6;

      users.knownGroups = with config.users; [ groups.nix.name ];
      users.knownUsers = with config.users; [ users.nix.name ];

      users.groups.nix.gid = 542;
      users.groups.nix.members = [ "nix" ];

      users.users.nix.createHome = true;
      users.users.nix.gid = config.users.groups.nix.gid;
      users.users.nix.home = "/Users/nix";
      users.users.nix.openssh.authorizedKeys.keys =
        config.users.users.${username}.openssh.authorizedKeys.keys;
      users.users.nix.shell = pkgs.bashInteractive;
      users.users.nix.uid = config.users.groups.nix.gid;

      users.users.root.home = "/var/root";
      users.users.root.openssh.authorizedKeys.keys =
        config.users.users.${username}.openssh.authorizedKeys.keys;
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

    (mkIf config.nixelium.profile.vm.enable {
      nixelium.system.isVirtual = true;
    })

    #(mkIf self.nixosConfigurations.osmium.config.nixelium.build.enable {
    #  nix.buildMachines = [
    #    {
    #      hostName = "osmium.ghost-ordinal.ts.net";
    #      maxJobs = 8;
    #      protocol = "ssh-ng";
    #      sshKey = "${config.users.users.root.home}/.ssh/id_osmium_nix";
    #      sshUser = "nix";
    #      supportedFeatures = [
    #        "benchmark"
    #        "big-parallel"
    #        "kvm"
    #        "nixos-test"
    #      ];
    #      systems = [
    #        "aarch64-linux"
    #        "x86_64-linux"
    #      ];
    #    }
    #  ];
    #})
  ];
}
