{ lib, config, user, ... }:

with lib;
let
  cfg = config.modules.desktop;
in {
  options.modules.desktop.services = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable services.";
      type = types.bool;
    };
  };

  config = mkIf cfg.services.enable {
    users.users."${user}".extraGroups = [ "video" ];

    services = {
      printing.enable = true;
      flatpak.enable = true;
      colord.enable = true;
      fwupd.enable = true;
      pipewire = {
        enable = true;
        wireplumber.enable = true;
        pulse.enable = true;
        jack.enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
      };
    };
  };
}
