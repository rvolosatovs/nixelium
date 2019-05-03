{ config, pkgs, ... }:

{
  environment.systemPackages = [
    config.services.skhd.package
  ];

  fonts.enableFontDir = true;
  fonts.fonts = with pkgs; [
    comic-relief
    fira
    furaCode
    roboto-slab
    siji
    symbola
    unifont
  ];

  services.skhd.enable = true;

  system.defaults.dock.autohide = true;
  system.defaults.dock.mru-spaces = false;
  system.defaults.dock.orientation = "right";
  system.defaults.dock.showhidden = true;

  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.finder.FXEnableExtensionChangeWarning = false;
  system.defaults.finder.QuitMenuItem = true;

  system.defaults.trackpad.Clicking = true;
  system.defaults.trackpad.TrackpadRightClick = true;
  system.defaults.trackpad.TrackpadThreeFingerDrag = true;

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;
}
