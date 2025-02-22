{ ... }:

{
  modules = {
    development.enable = false;
    apps = {
      enable = true;
      discord.enable = true;
      firefox.enable = true;
      minecraft.enable = true;
      ghostty.enable = true;
    };
  };
}
