{ pkgs, ... }:

{
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  environment.systemPackages = [
    pkgs.coreutils
  ];
}
