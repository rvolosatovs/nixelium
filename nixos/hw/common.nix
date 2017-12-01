{ ... }:

{
  loader.grub.enable = false;
  loader.systemd-boot.enable = true;
  loader.efi.canTouchEfiVariables = true;
}
