inputs: {
  # TODO: migrate install ISOs
  #install-aarch64 = import ./install-aarch64 inputs;
  #install-x86_64 = import ./install-x86_64 inputs;

  aarch64-linux-vm-nixvm = import ./aarch64-linux-vm-nixvm inputs;
  cobalt = import ./cobalt inputs;
  osmium = import ./osmium inputs;
}
