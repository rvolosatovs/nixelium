inputs: {
  # TODO: migrate install ISOs
  #install-aarch64 = import ./install-aarch64 inputs;
  #install-x86_64 = import ./install-x86_64 inputs;

  linux-aarch64-vm-nixvm = import ./linux-aarch64-vm-nixvm inputs;

  cobalt = import ./cobalt inputs;
  osmium = import ./osmium inputs;
}
