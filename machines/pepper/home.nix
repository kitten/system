{ ... }:

{
  modules = {
    desktop.enable = true;
    development.enable = false;
    apps = {
      enable = true;
      discord.enable = true;
      ghostty.enable = true;
      zen-browser.enable = true;
    };
  };
}
