(import ./nixops/hosts) // {
  network = {
    description = "My infrastructure";
    enableRollback = true;
  };
}
