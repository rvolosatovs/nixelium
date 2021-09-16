{ config, pkgs, lib, ... }:
let
  cfg = config.resources;

  ipType = lib.types.strMatching "([0-255]\.){4}";

  schemes.tomorrow-night.base00 = "1d1f21";
  schemes.tomorrow-night.base01 = "282a2e";
  schemes.tomorrow-night.base02 = "373b41";
  schemes.tomorrow-night.base03 = "969896";
  schemes.tomorrow-night.base04 = "b4b7b4";
  schemes.tomorrow-night.base05 = "c5c8c6";
  schemes.tomorrow-night.base06 = "e0e0e0";
  schemes.tomorrow-night.base07 = "ffffff";
  schemes.tomorrow-night.base08 = "cc6666";
  schemes.tomorrow-night.base09 = "de935f";
  schemes.tomorrow-night.base0A = "f0c674";
  schemes.tomorrow-night.base0B = "b5bd68";
  schemes.tomorrow-night.base0C = "8abeb7";
  schemes.tomorrow-night.base0D = "81a2be";
  schemes.tomorrow-night.base0E = "b294bb";
  schemes.tomorrow-night.base0F = "a3685a";
in
{
  options.resources = with lib; {
    email = mkOption {
      type = types.strMatching ".+@.+\..+";
      example = "foobar@example.com";
      description = "Email address";
    };

    username = mkOption {
      type = types.str;
      example = "foobar";
      description = "Username";
    };

    fullName = mkOption {
      type = types.str;
      example = "John Doe";
      description = "Full name";
    };

    domainName = mkOption {
      type = types.str;
      example = "example.com";
      default = "local";
      description = "Domain name";
    };

    base16.theme = mkOption {
      type = types.str;
      example = "tomorrow-night";
      default = "tomorrow-night";
      description = "Base16 theme name";
    };

    base16.colors.base00 = mkOption {
      type = types.str;
      visible = false;
      default = schemes."${cfg.base16.theme}".base00;
    };

    base16.colors.base01 = mkOption {
      type = types.str;
      visible = false;
      default = schemes."${cfg.base16.theme}".base01;
    };

    base16.colors.base02 = mkOption {
      type = types.str;
      visible = false;
      default = schemes."${cfg.base16.theme}".base02;
    };

    base16.colors.base03 = mkOption {
      type = types.str;
      visible = false;
      default = schemes."${cfg.base16.theme}".base03;
    };

    base16.colors.base04 = mkOption {
      type = types.str;
      visible = false;
      default = schemes."${cfg.base16.theme}".base04;
    };

    base16.colors.base05 = mkOption {
      type = types.str;
      visible = false;
      default = schemes."${cfg.base16.theme}".base05;
    };

    base16.colors.base06 = mkOption {
      type = types.str;
      visible = false;
      default = schemes."${cfg.base16.theme}".base06;
    };

    base16.colors.base07 = mkOption {
      type = types.str;
      visible = false;
      default = schemes."${cfg.base16.theme}".base07;
    };

    base16.colors.base08 = mkOption {
      type = types.str;
      visible = false;
      default = schemes."${cfg.base16.theme}".base08;
    };

    base16.colors.base09 = mkOption {
      type = types.str;
      visible = false;
      default = schemes."${cfg.base16.theme}".base09;
    };

    base16.colors.base0A = mkOption {
      type = types.str;
      visible = false;
      default = schemes."${cfg.base16.theme}".base0A;
    };

    base16.colors.base0B = mkOption {
      type = types.str;
      visible = false;
      default = schemes."${cfg.base16.theme}".base0B;
    };

    base16.colors.base0C = mkOption {
      type = types.str;
      visible = false;
      default = schemes."${cfg.base16.theme}".base0C;
    };

    base16.colors.base0D = mkOption {
      type = types.str;
      visible = false;
      default = schemes."${cfg.base16.theme}".base0D;
    };

    base16.colors.base0E = mkOption {
      type = types.str;
      visible = false;
      default = schemes."${cfg.base16.theme}".base0E;
    };

    base16.colors.base0F = mkOption {
      type = types.str;
      visible = false;
      default = schemes."${cfg.base16.theme}".base0F;
    };

    duckduckgo.key = mkOption {
      type = types.str;
      description = "DuckDuckGo key";
    };

    graphics.enable = mkEnableOption "graphical user interface";

    histsize = mkOption {
      type = types.ints.unsigned;
      default = 10000;
      description = "HISTSIZE value";
    };

    ssh.publicKeys = mkOption {
      type = with types; listOf str;
      example = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFSZ+ZWFCat0Fvog7XpS7mnNK9Mig+bi9LRqTHofBzIe" ];
      description = "Public SSH keys to allow access to";
    };

    gpg.publicKey.fingerprint = mkOption {
      type = types.strMatching "[[:alnum:]]{40}";
      description = "GPG key fingerprint";
    };

    deluge.localclientPassword = mkOption {
      type = types.str;
      description = "Deluge local client password";
    };

    deluge.port = mkOption {
      type = types.int;
      description = "Deluge daemon port";
    };

    deluge.userPassword = mkOption {
      type = types.str;
      description = "Deluge user client password";
    };

    miniflux.adminPassword = mkOption {
      type = types.str;
      description = "Miniflux admin password";
    };

    quake3.privatePassword = mkOption {
      type = types.str;
      description = "quake3 private password";
    };

    quake3.rconPassword = mkOption {
      type = types.str;
      description = "quake3 rcon password";
    };

    quake3.serverPassword = mkOption {
      type = types.str;
      description = "quake3 server password";
    };

    soundcloud.token = mkOption {
      type = types.str;
      description = "SoundCloud API token";
    };

    spotify.username = mkOption {
      type = types.str;
      description = "Spotify username";
    };

    spotify.password = mkOption {
      type = types.str;
      description = "Spotify password";
    };

    spotify.clientID = mkOption {
      type = types.str;
      description = "Spotify client ID";
    };

    spotify.clientSecret = mkOption {
      type = types.str;
      description = "Spotify client secret";
    };

    wireguard.presharedKey = mkOption {
      type = types.str;
      description = "Wireguard preshared key";
    };

    wireguard.port = mkOption {
      type = types.int;
      description = "Wireguard server port";
    };

    programs = let
      progOption = {
        options = {
          executable = mkOption {
            type = types.submodule {
              options = {
                name = mkOption {
                  type = types.str;
                  description = "Name of the executable";
                };

                path = mkOption {
                  type = types.str;
                  description = "Absolute path to the executable";
                  readOnly = true;
                };
              };
            };
            description = "Executable";
          };

          package = mkOption {
            type = types.package;
            description = "Package";
          };
        };
      };

      mkProgOption = args: mkOption args // {
        type = if args ? type then args.type else types.submodule progOption;
        apply = (opt:
        let
          _opt = if args ? apply then args.apply opt else opt;
        in rec {
          inherit (_opt) package;
          executable = _opt.executable // {
            path = "${package}/bin/${executable.name}";
          };
        });
      };
    in
    {
      browser = mkProgOption {
        example.package = pkgs.chromium;
        example.executable.name = "chromium";
        description = "Web browser";
      };

      editor = mkProgOption {
        example.package = pkgs.neovim;
        example.executable.name = "nvim";
        description = "Text editor";
      };

      mailer = mkProgOption {
        example.package = pkgs.thunderbird;
        example.executable.name = "thunderbird";
        description = "Email client";
      };

      pager = mkProgOption {
        example.package = pkgs.less;
        example.executable.name = "less";
        description = "Pager";
      };

      shell = mkProgOption {
        type = types.submodule {
          options = {
            executable = progOption.options.executable;
            package = mkOption {
              type = types.shellPackage;
              description = progOption.options.package.description;
            };
          };
        };
        example.package = pkgs.zsh;
        example.executable.name = "zsh";
        description = "Shell";
      };

      terminal = mkProgOption {
        example.package = pkgs.kitty;
        example.executable.name = "kitty";
        description = "Terminal emulator";
      };
    };
  };
}
