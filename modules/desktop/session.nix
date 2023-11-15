{ pkgs, lib, user, ... }:

{
  boot.plymouth.enable = true;

  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      plasma5 = {
        enable = true;
        useQtScaling = true;
      };
    };
    displayManager = {
      defaultSession = "plasmawayland";
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

  environment.plasma5 = {
    excludePackages = with pkgs.libsForQt5; [
      elisa
      gwenview
      oxygen
      oxygen-sounds
      khelpcenter
      konsole
      plasma-browser-integration
      plank-player
      aura-browser
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
