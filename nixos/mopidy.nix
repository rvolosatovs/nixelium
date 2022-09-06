{
  config,
  pkgs,
  ...
}: {
  services.mopidy.enable = true;
  services.mopidy.configuration = with config.resources; ''
    [core]
    restore_state = true
    [local]
    enabled = false
    [soundcloud]
    explore_songs = 25
    [spotify]
    bitrate = 320
    timeout = 30
    [spotify/tunigo]
    enabled = true
    [youtube]
    enabled = true
    [audio]
    mixer = software
    mixer_volume =
    output = pulsesink server=127.0.0.1
    buffer_time =
  '';
  services.mopidy.extensionPackages = with pkgs; [
    #mopidy-mpris TODO: make it work
    mopidy-iris
    mopidy-local-images
    mopidy-local-sqlite
    mopidy-soundcloud
    mopidy-spotify
    mopidy-spotify-tunigo
    mopidy-youtube
  ];

  users.users.${config.resources.username}.extraGroups = [
    "mopidy"
  ];
}
