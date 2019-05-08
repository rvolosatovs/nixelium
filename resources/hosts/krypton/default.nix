{
  imports = [
    ./../..
  ];

  config.resources = {
    base16.theme = "tomorrow-night";
    email = "roman@thethingsnetwork.org";
    gpg.publicKey.fingerprint = "76A19920EC6421DF1D2B36C9E2F62C4B84AB2D0B";
    graphics.enable = true;
  };
}
