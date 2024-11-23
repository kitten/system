{ lib, config, inputs, pkgs, user, ... }:

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

    environment.systemPackages = let
      umu = (inputs.umu.packages.${pkgs.system}.umu.override {
        version = "${inputs.umu.shortRev}";
      });
    in [
      umu
      (pkgs.lutris.override {
        extraPkgs = (pkgs: with pkgs; [
          wineWowPackages.stagingFull
          gamemode
          umu
        ]);
      })
    ];

    programs = {
      gamemode.enable = true;
      gamescope = {
        enable = true;
        args = [ "--adaptive-sync" "--hdr-enabled" "--rt" "--immediate-flips" "-f" "-S" "stretch" "-W" "2560" "-H" "1440" "-r" "360" ];
      };
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
      };
    };

    networking.hosts."0.0.0.0" = [ "ipv6check-http.steamserver.net" ];
  };
}
