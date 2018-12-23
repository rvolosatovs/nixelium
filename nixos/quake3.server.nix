{ config, pkgs, ... }:
let
  port = 27960;
in
  {
    systemd.services.ioquake3.after = [ "network.target" ];
    systemd.services.ioquake3.description = "ioquake3 server";
    systemd.services.ioquake3.enable = true;
    systemd.services.ioquake3.serviceConfig.ExecStart = let
      cfg = pkgs.writeTextFile {
        name = "server.cfg";
        destination = "/baseq3/server.cfg";
        text = ''
          g_needpass "0"
          set g_allowvote "1"
          set net_port ${builtins.toString port}
          seta bot_enable "1"
          seta bot_minplayers "2"
          seta bot_nochat "1"
          seta fraglimit "25"
          seta g_forcerespawn "0"
          seta g_gametype "0"
          seta g_inactivity "300"
          seta g_motd "Time to fight!"
          seta g_quadfactor "3"
          seta g_weaponrespawn "5"
          seta pmove_fixed "1"
          seta r_smp "1"
          seta rconpassword "${config.resources.ioquake3.rconPassword}"
          seta sv_allowdownload "0"
          seta sv_floodProtect "1"
          seta sv_fps "60"
          seta sv_hostname "Stinky"
          seta sv_maxclients "12"
          seta sv_maxRate "10000"
          seta sv_privateClients "2"
          seta sv_privatePassword "${config.resources.ioquake3.privatePassword}"
          seta sv_pure "0"
          seta sv_strictauth "0"
          seta timelimit "15"
          sets ".Admin" "${config.resources.fullName}"
          sets ".email" "${config.resources.email}"
          set d1 "map q3dm1 ; set nextmap vstr d2"
          set d2 "map q3dm2 ; set nextmap vstr d3"
          set d3 "map q3dm3 ; set nextmap vstr d4"
          set d4 "map q3dm4 ; set nextmap vstr d5"
          set d5 "map q3dm5 ; set nextmap vstr d6"
          set d6 "map q3dm6 ; set nextmap vstr d7"
          set d7 "map q3dm7 ; set nextmap vstr d8"
          set d8 "map q3dm8 ; set nextmap vstr d9"
          set d9 "map q3dm9 ; set nextmap vstr d1"
          vstr d1
        '';
      };

      quake = pkgs.quake3wrapper {
        name = "ioquake3-full-server";
        description = "Full ioquake3 server";
        paks = [ pkgs.quake3pointrelease pkgs.quake3ProprietaryPaks cfg ];
      };
    in "${quake}/bin/quake3-server +set dedicated 2 +exec server.cfg";

    systemd.services.ioquake3.serviceConfig.User = "ioquake3";
    systemd.services.ioquake3.wantedBy = [ "multi-user.target" ];

    networking.firewall.allowedTCPPorts = [ port ];
    networking.firewall.allowedUDPPorts = [ port ];

    users.users.ioquake3 = {
      createHome = true;
      description = "ioquake3 user";
      home = "/var/lib/ioquake3";
    };
  }
