{ config, pkgs, ... }:
let
  port = 27960;
in
  {
    systemd.services.quake3.after = [ "network.target" ];
    systemd.services.quake3.description = "quake3 server";
    systemd.services.quake3.enable = true;
    systemd.services.quake3.serviceConfig.ExecStart = let
      cfg = pkgs.writeTextFile {
        name = "server.cfg";
        destination = "/baseq3/server.cfg";
        text = ''
          set bot_enable "1"
          set bot_minplayers "2"
          set bot_nochat "1"
          set fraglimit "25"
          set g_allowvote "1"
          set g_forcerespawn "0"
          set g_gametype "0"
          set g_inactivity "300"
          set g_motd "Time to fight!"
          set g_needpass "1"
          set g_password "${config.resources.quake3.serverPassword}"
          set g_quadfactor "3"
          set g_weaponrespawn "10"
          set net_port ${builtins.toString port}
          set pmove_fixed "1"
          set r_smp "1"
          set rconpassword "${config.resources.quake3.rconPassword}"
          set sv_allowdownload "0"
          set sv_floodProtect "1"
          set sv_fps "60"
          set sv_hostname "The Things Bloodshed"
          set sv_maxclients "12"
          set sv_maxRate "10000"
          set sv_privateClients "2"
          set sv_privatePassword "${config.resources.quake3.privatePassword}"
          set sv_pure "1"
          set sv_strictauth "0"
          set timelimit "15"
          sets ".Admin" "${config.resources.fullName}"
          sets ".email" "${config.resources.email}"
          set d1 "map q3dm1 ; set nextmap vstr d2"
          set d2 "map q3dm2 ; set nextmap vstr d3"
          set d3 "map q3dm3 ; set nextmap vstr d4"
          set d4 "map q3dm4 ; set nextmap vstr d5"
          set d5 "map q3dm5 ; set nextmap vstr d6"
          set d6 "map q3dm6 ; set nextmap vstr d1"
          vstr d1
        '';
      };

      quake = pkgs.quake3wrapper {
        name = "quake3-server";
        description = "Quake3 server";
        paks = with pkgs; [ quake3pointrelease quake3hires quake3Paks cfg ];
      };
    in "${quake}/bin/quake3-server +set dedicated 1 +exec server.cfg";

    systemd.services.quake3.serviceConfig.User = "quake3";
    systemd.services.quake3.wantedBy = [ "multi-user.target" ];

    networking.firewall.allowedTCPPorts = [ port ];
    networking.firewall.allowedUDPPorts = [ port ];

    users.users.quake3 = {
      createHome = true;
      description = "quake3 user";
      home = "/var/lib/quake3";
    };
  }
