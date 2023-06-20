{ pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      mainBar = {
        layer = "top";
        mode = "dock";
        exclusive = true;
        passthrough = false;
        height = 32;
        spacing = 6;
        margin = "0";
        fixed-center = true;
        ipc = true;

        modules-left = [ "wlr/workspaces" ];
        modules-right = [ "tray" "battery" "clock" ];
      };
    };
  };
}
