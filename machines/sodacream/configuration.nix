{ user, ... }:

{
  imports = [
    ./hardware.nix
  ];

  users.users."${user}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$DEmCOeiSFe6ymGox$WMWddbT9PkkfDT6JS4WuJsM3mQHI0e9kg0t42UowO79dWAcSU0K//KKlcebSosoMRz5mUEw5TFvbrv1aRHqYa/";
  };

  modules = {
    desktop = {
      enable = true;
      rawaccel.enable = false;
    };
    fonts.enable = true;
    server = {
      enable = true;
      sshd.enable = true;
      tailscale.enable = true;
    };
  };

  system.stateVersion = "25.05";
}

