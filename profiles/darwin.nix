{ pkgs, ... }:

{
  imports = [
    ../config/yabai.nix
    ../config/skhd.nix
  ];

  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };

    defaults = {
      dock = {
        autohide = true;
        tilesize = 46;
      };
      NSGlobalDomain = {
        InitialKeyRepeat = 10;
        KeyRepeat = 2;
      };
    };
  };

  environment.systemPackages = [
    pkgs.coreutils
  ];
}
