{ pkgs, lib, user, ... }:

{
  boot.plymouth.enable = true;

  services.desktopManager.plasma6.enable = true;

  services.displayManager = {
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
