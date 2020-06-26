{ pkgs, ... }:

{
  imports = [
    ../config/yabai.nix
    ../config/skhd.nix
  ];

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  environment.systemPackages = [
    pkgs.coreutils
  ];
}
