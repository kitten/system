{ hyprland, pkgs, ... }:

{
  imports = [
    hyprland.nixosModules.default
  ];

  environment.systemPackages = with pkgs; [
    wl-clipboard
    xdg-utils
  ];

  services.xserver = {
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

  programs.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
      hidpi = true;
    };
  };
}
