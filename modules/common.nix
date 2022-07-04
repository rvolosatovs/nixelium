{
  lib,
  pkgs,
  ...
}: {
  documentation.nixos.enable = false;

  environment.shells = [
    pkgs.bashInteractive
  ];

  environment.systemPackages = [
    pkgs.curl
    pkgs.emacs
    pkgs.nano
    pkgs.openssl
  ];

  networking.firewall.enable = true;

  nix.binaryCaches = [
    "https://cache.nixos.org"
    "https://enarx.cachix.org"
  ];
  nix.binaryCachePublicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "enarx.cachix.org-1:Izq345bPMThAWUW830X3uoGTTBjXW7ltGlfTBErgm4w="
  ];
  nix.extraOptions = "experimental-features = nix-command flakes";
  nix.gc.automatic = true;
  nix.optimise.automatic = true;
  nix.requireSignedBinaryCaches = true;
  nix.settings.auto-optimise-store = true;
  nix.settings.allowed-users = [
    "@wheel"
    "root"
  ];
  nix.settings.trusted-users = [
    "root"
  ];

  programs.bash.enableCompletion = true;

  programs.fish.enable = true;

  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;
  programs.neovim.viAlias = true;
  programs.neovim.vimAlias = true;

  programs.zsh.enable = true;
  programs.zsh.enableBashCompletion = true;
  programs.zsh.autosuggestions.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.interactiveShellInit = "source '${pkgs.grml-zsh-config}/etc/zsh/zshrc'";

  security.acme.acceptTerms = true;

  security.sudo.enable = true;

  services.nginx.enable = true;
  services.nginx.sslProtocols = "TLSv1.3";
  services.nginx.sslCiphers = lib.concatStringsSep ":" [
    "ECDHE-ECDSA-AES256-GCM-SHA384"
    "ECDHE-ECDSA-AES128-GCM-SHA256"
    "ECDHE-ECDSA-CHACHA20-POLY1305"
  ];
  services.nginx.appendHttpConfig = ''
    proxy_ssl_protocols TLSv1.3;
    ssl_prefer_server_ciphers on;
  '';

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;
  services.openssh.startWhenNeeded = true;

  system.stateVersion = "22.05";
}
