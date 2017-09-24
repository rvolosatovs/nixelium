{ pkgs, secrets, ... }:
{
  services = {
    mopidy = {
      enable = true;
      configuration = ''
                    [core]
                    restore_state = true
                    [local]
                    enabled = false
                    [soundcloud]
                    auth_token = ${secrets.soundcloud.token}
                    explore_songs = 25
                    [spotify]
                    username = ${secrets.spotify.username}
                    password = ${secrets.spotify.password}
                    client_id = ${secrets.spotify.clientID}
                    client_secret = ${secrets.spotify.clientSecret}
                    bitrate = 320
                    timeout = 30
                    [spotify/tunigo]
                    enabled = true
                    [youtube]
                    enabled = true
                    [audio]
                    mixer = software
                    mixer_volume =
                    output = autoaudiosink
                    buffer_time =
      '';
      extensionPackages = with pkgs; [
        mopidy-soundcloud
        mopidy-iris
        mopidy-local-images
        mopidy-local-sqlite
        #mopidy-mpris
        mopidy-spotify
        mopidy-spotify-tunigo
        mopidy-youtube
      ];
    };
  };
}
