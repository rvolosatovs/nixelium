{
  allowBroken = false;
  allowUnfree = true;
  allowUnfreeRedistributable = true;

  permittedInsecurePackages = [
    "p7zip-16.02"
  ];

  pulseaudio = true;

  wine.build = "wineWow";
  wine.release = "staging";
}
