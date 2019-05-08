{ config, pkgs, ... }:

{
  imports = [
    ./skhd.nix
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

  system.defaults.dock.autohide = true;
  system.defaults.dock.mru-spaces = false;
  system.defaults.dock.orientation = "right";
  system.defaults.dock.showhidden = true;

  system.defaults.finder._FXShowPosixPathInTitle = false;
  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.finder.FXEnableExtensionChangeWarning = false;
  system.defaults.finder.QuitMenuItem = true;

  system.defaults.NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;
  system.defaults.NSGlobalDomain."com.apple.trackpad.enableSecondaryClick" = true;
  system.defaults.NSGlobalDomain."com.apple.trackpad.scaling" = "2.0";
  system.defaults.NSGlobalDomain."com.apple.trackpad.trackpadCornerClickBehavior" = 1;
  system.defaults.NSGlobalDomain.AppleKeyboardUIMode = 3;
  system.defaults.NSGlobalDomain.AppleMeasurementUnits = "Centimeters";
  system.defaults.NSGlobalDomain.AppleMetricUnits = 1;
  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = true;
  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
  system.defaults.NSGlobalDomain.AppleShowScrollBars = "Automatic";
  system.defaults.NSGlobalDomain.AppleTemperatureUnit = "Celsius";
  system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = true;
  system.defaults.NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = true;
  system.defaults.NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = true;
  system.defaults.NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
  system.defaults.NSGlobalDomain.NSDisableAutomaticTermination = true;
  system.defaults.NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;

  system.defaults.trackpad.Clicking = true;
  system.defaults.trackpad.TrackpadRightClick = true;
  system.defaults.trackpad.TrackpadThreeFingerDrag = true;

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;
}
