{ user, ... }:

{
  imports = [
    ./hardware.nix
  ];

  users.users."${user}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    hashedPassword = "$6$DEmCOeiSFe6ymGox$WMWddbT9PkkfDT6JS4WuJsM3mQHI0e9kg0t42UowO79dWAcSU0K//KKlcebSosoMRz5mUEw5TFvbrv1aRHqYa/";
  };

  modules = {
    desktop = {
      enable = true;
    };
    server = {
      enable = true;
      sshd.enable = true;
      tailscale.enable = true;
    };
    apps = {
      enable = true;
      games.enable = true;
    };
  };

  system.stateVersion = "24.11";
}
