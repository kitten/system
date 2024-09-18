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
      fontDir.enable = true;

      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        roboto-mono
        inter
      ];

      fontconfig.defaultFonts = {
        serif = [ "Noto Serif" "Noto Color Emoji" ];
        sansSerif = [ "Inter" "Noto Color Emoji" ];
        monospace = [ "Dank Mono" "Roboto Mono" "Noto Color Emoji" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
