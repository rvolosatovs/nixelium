{
  benefice-staging,
  benefice-testing,
  drawbridge-production,
  drawbridge-staging,
  drawbridge-testing,
  enarx,
  steward-production,
  steward-staging,
  steward-testing,
  ...
}: final: prev: let
  fromInput = name: src:
    final.stdenv.mkDerivation {
      inherit name;
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/bin
        install ${src} $out/bin/${name}
      '';
    };
in {
  benefice.testing = benefice-testing.packages.x86_64-linux.benefice-debug-x86_64-unknown-linux-musl;
  benefice.staging = fromInput "benefice" benefice-staging;

  drawbridge.testing = drawbridge-testing.packages.x86_64-linux.drawbridge-debug-x86_64-unknown-linux-musl;
  drawbridge.staging = fromInput "drawbridge" drawbridge-staging;
  drawbridge.production = fromInput "drawbridge" drawbridge-production;

  enarx = fromInput "enarx" enarx;

  steward.testing = steward-testing.packages.x86_64-linux.steward-x86_64-unknown-linux-musl;
  steward.staging = fromInput "steward" steward-staging;
  steward.production = fromInput "steward" steward-production;
}
