{
  allowBroken = false;
  allowUnfree = true;
  allowUnfreeRedistributable = true;

  config.firefox.enableAdobeFlash = false;
  config.firefox.drmSupport = true;

  permittedInsecurePackages = [
    "python2.7-certifi-2021.10.8"
    "python2.7-pyjwt-1.7.1"
  ];

  wine.build = "wineWow";
  wine.release = "staging";
}
