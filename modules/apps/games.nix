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

  config = let
    umu = (inputs.umu.packages.${pkgs.system}.umu.override {
      version = "${inputs.umu.shortRev}";
    });
  in mkIf (cfg.enable && cfg.games.enable) {
    boot.kernel.sysctl = {
      "kernel.unprivileged_userns_clone" = true;
    };

    environment.sessionVariables.PROTONPATH = "${pkgs.proton-ge-bin.steamcompattool}/";
    users.users."${user}".extraGroups = [ "gamemode" ];
    hardware.steam-hardware.enable = true;
    services.system76-scheduler.enable = true;

    environment.systemPackages = [
      umu
      (pkgs.lutris.override {
        extraPkgs = (pkgs: with pkgs; [ gamemode ]);
      })
    ];

    programs = {
      gamemode.enable = true;
      gamescope = {
        enable = true;
        args = [ "--adaptive-sync" "--expose-wayland" "--hdr-enabled" "--rt" "--immediate-flips" "-S" "fit" "-f" "-W" "2560" "-H" "1440" "-r" "360" ];
      };
      steam = {
        enable = true;
        package = pkgs.steam.override {
          extraPkgs = pkgs: with pkgs; [
            gamemode
          ];
        };
        remotePlay.openFirewall = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
      };
    };

    networking.hosts."0.0.0.0" = [ "ipv6check-http.steamserver.net" ];
  };
}
