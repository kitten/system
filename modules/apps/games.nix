{ lib, config, pkgs, user, ... }:

with lib;
let
  cfg = config.modules.apps;
in {
  options.modules.apps.games = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable games.";
      type = types.bool;
    };
  };

  config = mkIf (cfg.enable && cfg.games.enable) {
    users.users."${user}".extraGroups = [ "gamemode" ];

    hardware.steam-hardware.enable = true;
    services.system76-scheduler.enable = true;
    environment.systemPackages = [ pkgs.lutris ];

    programs = {
      gamemode.enable = true;
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
      };
    };

    networking.hosts."0.0.0.0" = [ "ipv6check-http.steamserver.net" ];
  };
}
