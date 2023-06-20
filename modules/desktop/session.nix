{ hyprland, ... }:

{
  imports = [
    hyprland.nixosModules.default
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
