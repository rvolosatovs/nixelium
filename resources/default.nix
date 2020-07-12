{ config, pkgs, lib,... }:
{
  imports = [
    ./../modules/resources.nix
  ];

  config.resources = with lib; mapAttrs (_: v: mkDefault v) {
    email = "rvolosatovs@riseup.net";
    username = "rvolosatovs";
    fullName = "Roman Volosatovs";

    ssh.publicKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFSZ+ZWFCat0Fvog7XpS7mnNK9Mig+bi9LRqTHofBzIe"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCzuZ07qrJQs1fAWiOy2liG7HQK7DoeHlYxQd66MO3OTWdsGNvLCL+ytP7wOPjUtUzSCXuePyjCIyk2bu0UNJARjvZRRRsHHyUs74PEbE5Ks10B1zAaVsB5aq0PLBKPaCOPwFI8wJoQL9rl5j71UIZrGCGXekK0wncRBSIXB5QZYMsHM4B6LaLhbEmQf+f19HMJHpveI32ljddBv0/5/S97M0iyG9WOWS0l3ijzJxPHVOgJ0PXYUIFh1z52wbrqyeFKDWMWUTC27GTvyri3r1bEEeaxGEfe3T6EHmbCNj+VSAssTVY9x5Ni5WTMyHjuUQEKdDy3C3JkQIsUZ+oHHhNpqeHL+qzh9RDqHh5UjG6FQyqNTBAjYWwnonDkNXjCAcLrImMIqlKwZyrF6qe+ZlZERffnMIe+VWZLe8ls1fgEZRNrnWN3ojc6iEgeNLO6AVLxMDGfrUCdUPoyq43VmQMgokr2qApgKXbToWGE3rscCri+OheyqIEGrskMQCU/00KeBJLEFCZ8TxmWhbc461TIlLHwyWSt9Hd0SoJ0RMJnvHl7mOT36itkkXXqUGE12cVd05bVGdovlWeZJd3t5JzwuSk8VWoiXDrSIaWK72IsfRgitsogp9HCI9i2a6blqm6gkvWec0UhbXzWQStSs2WO7xWt3vAsd6z44Vk49qwzZQ== openpgp:0xB52DA090"
    ];
    gpg.publicKey.fingerprint = "57CF72B72BBA3C88A68CFE153AC661943D80C89E";

    base16.theme = "tomorrow-night";

    programs = let
      pkgToProg = pkg: exe: {
        package = pkg;
        executable.name = exe;
      };
    in {
      editor.package = pkgs.neovim;
      editor.executable.name ="nvim";

      mailer.package = pkgs.mutt;
      mailer.executable.name ="mutt";

      pager.package = pkgs.less;
      pager.executable.name ="less";

      shell.package = pkgs.zsh;
      shell.executable.name ="zsh";

    } // optionalAttrs config.resources.graphics.enable {
      terminal.package = pkgs.kitty;
      terminal.executable.name ="kitty -1";

    } // optionalAttrs (config.resources.graphics.enable && pkgs.stdenv.isLinux) {
      browser.package = pkgs.firefox-wayland;
      browser.executable.name ="firefox";

      mailer.package = pkgs.thunderbird;
      mailer.executable.name ="thunderbird";
    };
  };
}
