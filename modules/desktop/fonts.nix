{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop;
in {
  options.modules.desktop.fonts = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable default fonts.";
      type = types.bool;
    };
  };

  config = mkIf cfg.fonts.enable {
    fonts = {
      fontDir = {
        enable = true;
        decompressFonts = true;
      };

      packages = with pkgs; [
        sf-pro
        sf-pro-mono
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
        roboto-mono
        inter
      ];

      fontconfig.defaultFonts = {
        serif = [ "Noto Serif" "Noto Color Emoji" ];
        sansSerif = [ "SF Pro Display" "Noto Color Emoji" ];
        monospace = [ "Dank Mono" "Roboto Mono" "Noto Color Emoji" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
