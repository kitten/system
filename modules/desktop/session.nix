{ hyprland, pkgs, lib, user, ... }:

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
        lightdm.enable = lib.mkForce false;
        gdm.enable = lib.mkForce false;
        defaultSession = "hyprland";
      };
    };
  };

  services.greetd = let
    hyprland_config = pkgs.writeText "greetd-hyprland-config" ''
      exec-once = ${lib.getExe pkgs.greetd.gtkgreet} -l --cmd ${hyprland_shell}; ${pkgs.hyprland}/bin/hyprctl dispatch exit
      misc {
        disable_hyprland_logo = true
        disable_splash_rendering = true
      }
    '';
    hyprland_shell = pkgs.writeShellScript "hyprland-shell" ''
      exec systemd-cat -t hyprland ${pkgs.hyprland}/bin/Hyprland
    '';
    hyprland_login = pkgs.writeShellScript "hyprland-login" ''
      exec ${pkgs.hyprland}/bin/Hyprland --config ${hyprland_config};
    '';
  in {
    enable = true;
    settings = {
      terminal.vt = 2;
      default_session = {
        command = "${pkgs.greetd.greetd}/bin/agreety --cmd ${hyprland_shell}";
      };
      initial_session = {
        command = "${hyprland_shell}";
        user = "${user}";
      };
    };
  };

  security = {
    polkit.enable = true;
    pam.services.greetd.enableGnomeKeyring = true;
  };

  programs = {
    dconf.enable = true;

    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = false;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  security.pam.services.swaylock = {};

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
