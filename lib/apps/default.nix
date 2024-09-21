inputs: {
  genCerts = {
    type = "app";
    program = import ./genCerts.nix inputs;
  };
}
