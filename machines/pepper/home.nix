{ pkgs, ... }:

{
  modules = {
    desktop = {
      enable = true;
      niri.settings.outputs."Samsung Electric Company Odyssey G60SD HNAX300205" = {
        variable-refresh-rate = true;
        mode = {
          width = 2560;
          height = 1440;
          refresh = 359.999;
        };
      };
    };
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
