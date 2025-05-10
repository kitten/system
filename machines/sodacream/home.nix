{ ... }: {
  modules = {
    desktop = {
      enable = true;
      hyprland.monitor = [ "eDP-1, preferred, 0x0, 1.6" ];
    };
    development = {
      enable = true;
      js.enable = true;
      zig.enable = true;
      terraform.enable = false;
      react-native.enable = false;
    };
    apps = {
      enable = true;
      ghostty.enable = true;
      zen-browser.enable = true;
      discord.enable = true;
      chromium.enable = true;
    };
  };
}
