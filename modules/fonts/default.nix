{ config, lib, helpers, ... }:

with lib;
let
  cfg = config.modules.fonts;
  fontsPath = if helpers.isDarwin then "/Library/Fonts" else "/usr/share/fonts/nonfree";
in {
  options.modules.fonts = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable fonts options.";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    age.secrets."DankMono-Regular.otf" = {
      symlink = false;
      file = ./encrypt/DankMono-Regular.otf.age;
      path = "${fontsPath}/DankMono-Regular.otf";
      mode = "755";
    };

    age.secrets."DankMono-Italic.otf" = {
      symlink = false;
      file = ./encrypt/DankMono-Italic.otf.age;
      path = "${fontsPath}/DankMono-Italic.otf";
      mode = "755";
    };

    age.secrets."DankMono-Bold.otf" = {
      symlink = false;
      file = ./encrypt/DankMono-Bold.otf.age;
      path = "${fontsPath}/DankMono-Bold.otf";
      mode = "755";
    };

    age.secrets."codicon.otf" = {
      symlink = false;
      file = ./encrypt/codicon.otf.age;
      path = "${fontsPath}/codicon.otf";
      mode = "755";
    };

    age.secrets."faicon.ttf" = {
      symlink = false;
      file = ./encrypt/faicon.ttf.age;
      path = "${fontsPath}/faicon.ttf";
      mode = "755";
    };
  };
}
