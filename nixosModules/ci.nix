# TODO: This should be merged with users.nix into a configurable NixOS module
{...}: let
  keys.ci = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBP5eXj567djd1G54kmt1U00gsFVOex0qNldmeRAHCol";
in {
  users.users.deploy.openssh.authorizedKeys.keys = with keys; [
    ci
  ];
}
