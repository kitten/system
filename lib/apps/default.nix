inputs: {
  genCerts = {
    type = "app";
    program = import ./genCerts.nix inputs;
  };
  restoreBackup = {
    type = "app";
    program = import ./restoreBackup.nix inputs;
  };
}
