{ config, pkgs, user, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/desktop
  ];

  users.users."${user}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    hashedPassword = "$6$DEmCOeiSFe6ymGox$WMWddbT9PkkfDT6JS4WuJsM3mQHI0e9kg0t42UowO79dWAcSU0K//KKlcebSosoMRz5mUEw5TFvbrv1aRHqYa/";
  };

  networking.networkmanager = {
    enable = true;
    wifi.powersave = true;
  };

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_GB.UTF-8";

  system.stateVersion = "23.05";
}
