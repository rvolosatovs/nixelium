{
  benefice-production,
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
}: final: prev: {
  benefice.testing = benefice-testing.packages.x86_64-linux.benefice-debug-x86_64-unknown-linux-musl;
  benefice.staging = benefice-staging.packages.x86_64-linux.benefice-x86_64-unknown-linux-musl;
  benefice.production = benefice-production.packages.x86_64-linux.benefice-x86_64-unknown-linux-musl;

  drawbridge.testing = drawbridge-testing.packages.x86_64-linux.drawbridge-debug-x86_64-unknown-linux-musl;
  drawbridge.staging = drawbridge-staging.packages.x86_64-linux.drawbridge-x86_64-unknown-linux-musl;
  drawbridge.production = drawbridge-production.packages.x86_64-linux.drawbridge-x86_64-unknown-linux-musl;

  enarx = enarx.packages.x86_64-linux.enarx-x86_64-unknown-linux-musl;

  # TODO: Use debug Steward build
  steward.testing = steward-testing.packages.x86_64-linux.steward-x86_64-unknown-linux-musl;
  steward.staging = steward-staging.packages.x86_64-linux.steward-x86_64-unknown-linux-musl;
  steward.production = steward-production.packages.x86_64-linux.steward-x86_64-unknown-linux-musl;
}
