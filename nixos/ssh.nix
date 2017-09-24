{ pkgs, ... }:
{
  services = {
    ssh = {
      askPassword = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
      startAgent = false;
    };
  };
}
