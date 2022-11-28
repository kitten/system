let
  inherit (import ../../nix/secrets.nix) readSecretFileContents;
in {
  home.file.".npmrc".text = ''
    update-notifier = off
    loglevel = warn
  '' + (readSecretFileContents ../../assets/npmrc);

  home.file.".yarnrc".text = ''
    disable-self-update-check true
    email phil@kitten.sh
    username philpl
  '';
}
