{ ... }:

{
  modules = {
    development.enable = false;
    apps = {
      enable = true;
      discord.enable = true;
      minecraft.enable = true;
      ghostty.enable = true;
      zen-browser.enable = true;
    };
  };
}
