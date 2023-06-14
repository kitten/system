let
  inherit (import ./channels.nix) __nixPath nixPath;
  pkgs = import <nixpkgs> { system = builtins.currentSystem; };
in rec {
  readSecretFile = path :
    pkgs.runCommand (baseNameOf (toString path)) {
      buildInputs = [ pkgs.openssl ];
    } ''
      openssl enc -d -aes-256-cbc -pbkdf2 -salt -base64 -in ${path} -out $out -kfile ${../.nix-secret}
    '';

  readSecretFileContents = path :
    builtins.readFile (readSecretFile path);
}
