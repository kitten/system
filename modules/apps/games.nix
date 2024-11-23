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
    environment.systemPackages = [
      (pkgs.lutris.override (prev: {
      steam.override (prev: {
        extraEnv = {
          STEAM_EXTRA_COMPAT_TOOLS_PATHS = makeSearchPathOutput "steamcompattool" "" [ pkgs.proton-ge-bin ];
        };
      }))
    ];

    programs = {
      gamemode.enable = true;
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
      };
    };

    networking.hosts."0.0.0.0" = [ "ipv6check-http.steamserver.net" ];
  };
}
