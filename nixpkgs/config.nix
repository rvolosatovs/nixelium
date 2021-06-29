{
  allowBroken = false;
  allowUnfree = true;
  allowUnfreeRedistributable = true;

  config.firefox.enableAdobeFlash = false;

  permittedInsecurePackages = [
    "p7zip-16.02"
    "python2.7-certifi-2019.11.28"
  ];

  pulseaudio = true;

  wine.build = "wineWow";
  wine.release = "staging";
}
