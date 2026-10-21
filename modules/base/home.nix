{ lib, config, pkgs, helpers, ... }:

let
  auth = import ../../lib/shell-env-wrapper.nix { inherit lib pkgs; };
  userSecrets = username: home:
    lib.concatLists (lib.mapAttrsToList (name: cfg:
      lib.imap0 (index: file: lib.nameValuePair
        (auth.secretName "${username}-${name}" index) {
          inherit file;
          owner = username;
          group = if helpers.isDarwin then "staff" else config.users.users.${username}.group;
          mode = "0400";
        }
      ) cfg.environmentFile.path
    ) (lib.filterAttrs (_: cfg:
      builtins.isAttrs cfg && cfg ? environmentFile && cfg.enable && cfg.environmentFile.enable
    ) (home.modules.development or { })));

in {
  age.secrets = lib.listToAttrs (lib.concatLists
    (lib.mapAttrsToList userSecrets config.home-manager.users));

  home-manager.sharedModules = [{
    manual.manpages.enable = false;
    xdg.enable = true;
    home = {
      stateVersion = "25.05";
      enableNixpkgsReleaseCheck = false;
    };
  }];
}
