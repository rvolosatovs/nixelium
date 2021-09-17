let
  # TODO: Refactor into a NixOS module.
  mkNginxTLSProxy = config: name: addr: {
    services.nginx.enable = true;
    services.nginx.virtualHosts."${name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = addr;
      serverName = "${name}.${config.resources.domainName}";
    };
  };

  mkBorgRepoPath = config: name: addr: "ssh://${config.services.borgbackup.repos.${name}.user}@${addr}:${toString (builtins.head config.services.openssh.ports)}${config.services.borgbackup.repos.${name}.path}";
  mkBorgWireguardRepoPath = config: name: mkBorgRepoPath config name config.network.wireguard.ip;
  mkBorgLocalRepoPath = config: name: mkBorgRepoPath config name "localhost";

  isLANip = lib: ip: lib.strings.hasPrefix "192.168." ip;
in
{
  network.description = "Private network of rvolosatovs";
  network.enableRollback = true;

  defaults.network.wireguard.enable = true;
  defaults.network.wireguard.interfaceName = "wg-private";
  defaults.network.wireguard.server.name = "neon";
  defaults.network.wireguard.subnet = "10.0.0.0/24";

  defaults.network.wireguard.extraPeers.zinc.ip = "10.0.0.30";
  defaults.network.wireguard.extraPeers.zinc.publicKey = "QLMUw+yvwXuuEsN06zB+Mj9n/VqD+k4VKa5o2GZrLAk=";

  cobalt = { config, lib, nodes, ... }: {
    imports = [
      ./../../../nixos/hosts/cobalt
      ./../../../vendor/secrets/nixops/hosts/cobalt
      ./../../profiles/laptop
    ];

    config = {
      deployment.hasFastConnection = true;

      network.wireguard.ip = "10.0.0.11";
      network.wireguard.publicKey = "6L6uG3nflK0GJt1468gV38jWX1BkVIj22XuqXtE99gk=";
      network.wireguard.privateKey = builtins.readFile ./../../../vendor/secrets/nixops/hosts/cobalt/wg.home.private;

      networking.privateIPv4 = "192.168.188.11";

      services.btrfs.snapshotBackup.enable = true;
      services.btrfs.snapshotBackup.subvolumes."/.snapshots" = {
        repo = mkBorgWireguardRepoPath nodes.neon.config "root";
        passphrase = builtins.readFile ./../../../vendor/secrets/nixos/hosts/neon/borg.root.repokey;
        ssh.key = builtins.readFile ./../../../vendor/secrets/nixops/hosts/cobalt/borg.root.id_ed25519;
      };
      services.btrfs.snapshotBackup.subvolumes."/home/.snapshots" = {
        repo = mkBorgWireguardRepoPath nodes.neon.config "home";
        passphrase = builtins.readFile ./../../../vendor/secrets/nixos/hosts/neon/borg.home.repokey;
        ssh.key = builtins.readFile ./../../../vendor/secrets/nixops/hosts/cobalt/borg.home.id_ed25519;
      };
    };
  };

  neon = { config, lib, nodes, ... }: {
    imports = [
      ./../../../nixos/hosts/neon
      ./../../../vendor/secrets/nixops/hosts/neon
      ./../../deluge.nix
      ./../../miniflux.nix
      ./../../profiles/server
    ];

    config = {
      deployment.hasFastConnection = isLANip lib config.deployment.targetHost;
      deployment.targetHost = config.networking.privateIPv4;

      network.wireguard.ip = "10.0.0.10";
      network.wireguard.publicKey = "weyoU0QBHrnjl+2dhibGm5um9+f2sZrg9x8SFd2AVhc=";
      network.wireguard.privateKey = builtins.readFile ./../../../vendor/secrets/nixops/hosts/neon/wg.home.private;

      networking.privateIPv4 = "192.168.188.10";
    };
  };

  # TODO: Rent a VPS and migrate oxygen.
  #oxygen = { config, lib, name, ... }: {
  #  imports = [
  #    ./../../../nixos/hosts/oxygen
  #    ./../../../nixos/wireguard.server.nix
  #    ./../../../vendor/secrets/nixops/hosts/oxygen
  #    ./../../miniflux.nix
  #    ./../../profiles/server
  #  ];
  #  
  #  config = with lib; mkMerge [
  #    (mkVPNNode lib)
  #    (mkNginxTLSProxy config "deluge" "http://${wg.hosts.neon.ip}:8112")
  #    (mkNginxTLSProxy config "jackett" "http://${wg.hosts.neon.ip}:9117")
  #    (mkNginxTLSProxy config "lidarr" "http://${wg.hosts.neon.ip}:8686")
  #    (mkNginxTLSProxy config "radarr" "http://${wg.hosts.neon.ip}:7878")
  #    (mkNginxTLSProxy config "sonarr" "http://${wg.hosts.neon.ip}:8989")
  #    {
  #      deployment.hasFastConnection = isLANip lib config.deployment.targetHost;
  #  
  #      deployment.keys.${wg.homeKeyName}.text = wg.hosts.${name}.privateKey;
  #  
  #      networking.wireguard.interfaces.${wg.home.interfaceName} = {
  #        peers = foldr (peerName: peers: peers ++ optional (peerName != name) {
  #          allowedIPs = [ "${wg.hosts.${peerName}.ip}/32" ];
  #          publicKey = wg.hosts.${peerName}.publicKey;
  #        }) [] wg.hostNames;
  #        privateKeyFile = config.deployment.keys.${wg.homeKeyName}.path;
  #      };
  #  
  #      systemd.services."wireguard-${wg.home.interfaceName}" = {
  #        after = [ "${wg.homeKeyName}-key.service" ];
  #        wants = [ "${wg.homeKeyName}-key.service" ];
  #      };
  #    }
  #  ];
  #};
}
