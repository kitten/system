{ config, ... }:

let
  home = config.home.homeDirectory;
in {
  age.secrets."nix-access-tokens.conf" = {
    symlink = true;
    path = "${home}/.cache/nix-access-tokens.conf";
    file = ../../modules/base/encrypt/nix-access-tokens.conf.age;
  };

  nix.extraOptions = ''
    !include ${config.age.secrets."nix-access-tokens.conf".path}
  '';
}
