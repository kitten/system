{ ... }:

{
  modules = {
    desktop = {
      enable = true;
      hyprland = {
        sensitivity = -0.5;
        monitor = [
          "desc:Samsung Electric Company Odyssey G60SD HNAX300205, 2560x1440@360, 0x0, 1, vrr, 1"
          "desc:LG Electronics 27GL850 005NTPC4Q200, preferred, auto, 1, transform, 1, vrr, 1"
        ];
      };
    };
    development.enable = false;
    apps = {
      enable = true;
      discord.enable = true;
      ghostty.enable = true;
      zen-browser.enable = true;
    };
  };
}
