{ config, pkgs, lib, ... } @ inputs:

let
  inherit (pkgs) stdenv;

  symlink = stdenv.hostPlatform.isLinux;

  fontsDir = if stdenv.hostPlatform.isDarwin then
    "/Library/Fonts" else "/share/fonts/opentype";
in

{
  age.secrets."DankMono-Regular.otf" = {
    inherit symlink;
    file = ./encrypt/DankMono-Regular.otf.age;
    path = "${fontsDir}/DankMono-Regular.otf";
    mode = "755";
  };

  age.secrets."DankMono-Italic.otf" = {
    inherit symlink;
    file = ./encrypt/DankMono-Italic.otf.age;
    path = "${fontsDir}/DankMono-Italic.otf";
    mode = "755";
  };

  age.secrets."DankMono-Bold.otf" = {
    inherit symlink;
    file = ./encrypt/DankMono-Bold.otf.age;
    path = "${fontsDir}/DankMono-Bold.otf";
    mode = "755";
  };

  age.secrets."codicon.otf" = {
    inherit symlink;
    file = ./encrypt/codicon.otf.age;
    path = "${fontsDir}/codicon.otf";
    mode = "755";
  };
}
