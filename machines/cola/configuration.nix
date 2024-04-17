{ config, pkgs, user, ... }:

{
  imports = [
    ./hardware.nix
    ./kernel.nix
    ./network.nix
    ./zfs.nix
    ../../modules/router
    ../../modules/server
    ../../modules/games
  ];

  users.users."${user}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$DEmCOeiSFe6ymGox$WMWddbT9PkkfDT6JS4WuJsM3mQHI0e9kg0t42UowO79dWAcSU0K//KKlcebSosoMRz5mUEw5TFvbrv1aRHqYa/";
  };

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_GB.UTF-8";

  system.stateVersion = "23.05";
}

