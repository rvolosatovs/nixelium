{self, ...}: {
  lib,
  pkgs,
  ...
}:
with lib; {
  documentation.nixos.enable = mkDefault false;

  networking.firewall.enable = mkDefault true;

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
  nix.package = pkgs.nixUnstable;
  nix.requireSignedBinaryCaches = true;
  nix.settings.auto-optimise-store = true;

  programs.neovim.defaultEditor = mkDefault true;
  programs.neovim.viAlias = mkDefault true;
  programs.neovim.vimAlias = mkDefault true;

  security.acme.acceptTerms = true;

  services.openssh.passwordAuthentication = false;
  services.openssh.permitRootLogin = mkForce "no";
  services.openssh.startWhenNeeded = true;

  services.nginx.recommendedGzipSettings = mkDefault true;
  services.nginx.recommendedOptimisation = mkDefault true;
  services.nginx.recommendedProxySettings = mkDefault true;
  services.nginx.recommendedTlsSettings = mkDefault true;
  services.nginx.sslProtocols = mkForce "TLSv1.3";
  services.nginx.sslCiphers = mkForce (concatStringsSep ":" [
    "ECDHE-ECDSA-AES256-GCM-SHA384"
    "ECDHE-ECDSA-AES128-GCM-SHA256"
    "ECDHE-ECDSA-CHACHA20-POLY1305"
  ]);
  services.nginx.appendHttpConfig = ''
    proxy_ssl_protocols TLSv1.3;
  '';

  system.stateVersion = "22.05";

  time.timeZone = "Etc/UTC";

  users.users.root.hashedPassword = mkForce "!"; # nothing hashes to `!`, so this disables root logins

  virtualisation.docker.autoPrune.enable = true;
}
