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
      hyprland = {
        input = {
          sensitivity = -0.5;
          kb_layout = "us";
        };
        monitor = [
          "desc:Samsung Electric Company Odyssey G60SD HNAX300205, 2560x1440@360, 0x0, 1, vrr, 1"
          "desc:LG Electronics 27GL850 005NTPC4Q200, preferred, auto, 1, transform, 1, vrr, 1"
        ];
      };
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
