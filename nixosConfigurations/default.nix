inputs: {
  install-aarch64 = import ./install-aarch64 inputs;
  install-x86_64 = import ./install-x86_64 inputs;

  cobalt = import ./cobalt inputs;
  osmium = import ./osmium inputs;
}
