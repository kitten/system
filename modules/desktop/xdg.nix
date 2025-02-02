{ lib, config, user, ... }:

with lib;
let
  cfg = config.modules.desktop;
in {
  options.modules.desktop.xdg = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable services.";
      type = types.bool;
    };
  };

  config = mkIf cfg.xdg.enable {
    home-manager.users.${user} = { ... }: {
      systemd.user.sessionVariables = {
        "NIXOS_OZONE_WL" = lib.mkDefault "1";
        "MOZ_ENABLE_WAYLAND" = lib.mkDefault "1";
      };
    };
  };
}
