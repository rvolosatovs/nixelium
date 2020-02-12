{ config, ... }:
{
  networking.firewall.allowedTCPPorts = [ config.resources.deluge.port ];

  services.deluge.config.add_paused = true;
  services.deluge.config.allow_remote = true;
  services.deluge.config.auto_managed = true;
  services.deluge.config.autoadd_enable = true;
  services.deluge.config.autoadd_location = "/var/lib/deluge/torrents";
  services.deluge.config.cache_expiry = 60;
  services.deluge.config.cache_size = 512;
  services.deluge.config.copy_torrent_file = false;
  services.deluge.config.daemon_port = config.resources.deluge.port;
  services.deluge.config.del_copy_torrent_file = false;
  services.deluge.config.dht = true;
  services.deluge.config.dont_count_slow_torrents = true;
  services.deluge.config.download_location = "/var/lib/deluge/downloads";
  services.deluge.config.enabled_plugins= [ "Label" ];
  services.deluge.config.enc_in_policy = 1;
  services.deluge.config.enc_level = 2;
  services.deluge.config.enc_out_policy = 1;
  services.deluge.config.ignore_limits_on_local_network = true;
  services.deluge.config.info_sent = 0.0;
  services.deluge.config.max_active_downloading = 3;
  services.deluge.config.max_active_limit = 8;
  services.deluge.config.max_active_seeding = 5;
  services.deluge.config.max_connections_global = 200;
  services.deluge.config.max_connections_per_second = 20;
  services.deluge.config.max_connections_per_torrent = -1;
  services.deluge.config.max_half_open_connections = 50;
  services.deluge.config.max_upload_slots_global = 4;
  services.deluge.config.move_completed = true;
  services.deluge.config.move_completed_path = "/var/lib/deluge/complete";
  services.deluge.config.new_release_check = false;
  services.deluge.config.prioritize_first_last_pieces = true;
  services.deluge.config.queue_new_to_top = true;
  services.deluge.config.random_outgoing_ports = false;
  services.deluge.config.random_port = false;
  services.deluge.config.rate_limit_ip_overhead = true;
  services.deluge.config.remove_seed_at_ratio = true;
  services.deluge.config.seed_time_limit = 180;
  services.deluge.config.seed_time_ratio_limit = 7;
  services.deluge.config.send_info = false;
  services.deluge.config.stop_seed_at_ratio = true;
  services.deluge.config.stop_seed_ratio = 2;
  services.deluge.config.torrentfiles_location = "/var/lib/deluge/torrents";
  services.deluge.config.upnp = true;

  services.deluge.declarative = true;
  services.deluge.enable = true;
  services.deluge.openFirewall = true;

  services.deluge.web.enable = true;
  services.deluge.web.openFirewall = true;

  users.users.${config.resources.username}.extraGroups = [ "deluge" ];
}
