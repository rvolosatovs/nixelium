{
  allowBroken = false;
  allowUnfree = true;
  allowUnfreeRedistributable = true;

  config.firefox.enableAdobeFlash = false;
  config.firefox.drmSupport = true;

  pulseaudio = true;

  wine.build = "wineWow";
  wine.release = "staging";
}
