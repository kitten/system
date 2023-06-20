{ config, pkgs, lib, helpers, ... } @ inputs:

let
  inherit (pkgs) stdenv;

  fontsDir = if helpers.isDarwin then
    "/Library/Fonts" else "/usr/share/fonts/nonfree";

in lib.mkMerge [
  {
    age.secrets."DankMono-Regular.otf" = {
      symlink = false;
      file = ./encrypt/DankMono-Regular.otf.age;
      path = "${fontsDir}/DankMono-Regular.otf";
      mode = "755";
    };

    age.secrets."DankMono-Italic.otf" = {
      symlink = false;
      file = ./encrypt/DankMono-Italic.otf.age;
      path = "${fontsDir}/DankMono-Italic.otf";
      mode = "755";
    };

    age.secrets."DankMono-Bold.otf" = {
      symlink = false;
      file = ./encrypt/DankMono-Bold.otf.age;
      path = "${fontsDir}/DankMono-Bold.otf";
      mode = "755";
    };

    age.secrets."codicon.otf" = {
      symlink = false;
      file = ./encrypt/codicon.otf.age;
      path = "${fontsDir}/codicon.otf";
      mode = "755";
    };
  }

  (helpers.linuxAttrs {
    fonts = {
      enableDefaultFonts = false;
      fontDir.enable = true;

      fonts = with pkgs; [
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
  })
]
