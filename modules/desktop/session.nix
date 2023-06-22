{ hyprland, pkgs, ... }:

{
  imports = [
    hyprland.nixosModules.default
  ];

  environment.systemPackages = with pkgs; [
    wl-clipboard
    wtype
    xdg-utils
  ];

  services = {
    power-profiles-daemon.enable = false;
    geoclue2.enable = true;

    dbus.packages = [ pkgs.gcr ];
    udev.packages = [ pkgs.gnome.gnome-settings-daemon ];
    gnome.gnome-keyring.enable = true;

    xserver = {
      enable = true;
      desktopManager.xterm.enable = false;
      displayManager = {
        defaultSession = "hyprland";
        gdm = {
          enable = true;
          wayland = true;
        };
      };
    };
  };

  security = {
    polkit.enable = true;
    pam.services.gdm.enableGnomeKeyring = true;
  };

  programs.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
      hidpi = true;
    };
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = false;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  systemd.user.services.polkit-agent = {
    description = "Polkit Authentication Agent";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
