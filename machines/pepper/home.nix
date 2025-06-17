{ pkgs, ... }:

{
  modules = {
    desktop.enable = true;
    development = {
      enable = true;
      zig.enable = false;
      react-native.enable = false;
      terraform.enable = false;
    };
    apps = {
      enable = true;
      discord.enable = true;
      ghostty.enable = true;
      zen-browser.enable = true;
      ollama = {
        enable = true;
        package = pkgs.ollama-rocm;
        flashAttention = true;
      };
    };
  };
}
