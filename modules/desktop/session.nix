{ pkgs, lib, user, ... }:

{
  boot.plymouth.enable = true;

  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      plasma6.enable = true;
    };
    displayManager = {
      defaultSession = "plasma";
      autoLogin = {
        inherit user;
        enable = true;
      };
      sddm = {
        enable = true;
        enableHidpi = true;
        wayland.enable = true;
      };
      lightdm.enable = lib.mkForce false;
      gdm.enable = lib.mkForce false;
    };
  };

  environment.plasma6 = {
    excludePackages = with pkgs.kdePackages; [
      elisa
      gwenview
      oxygen
      oxygen-sounds
      khelpcenter
      konsole
    ];
  };

  security = {
    polkit.enable = true;
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = false;
  };
}
