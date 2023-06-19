{ config, ... } @ inputs:

let
  inherit (import ../../lib/secrets.nix inputs) readSecretFileContents;
in {
  age.secrets."npmrc" = {
    symlink = true;
    path = "${config.home.homeDirectory}/.npmrc";
    file = ./encrypt/npmrc.age;
  };

  home.file.".yarnrc".text = ''
    disable-self-update-check true
    email phil@kitten.sh
    username philpl
  '';
}
