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

    hdr = mkOption {
      default = cfg.games.enable;
      example = true;
      description = "Whether to enable HDR.";
      type = types.bool;
    };
  };

  config = mkIf (cfg.enable && cfg.games.enable) {
    boot = {
      kernel.sysctl."kernel.unprivileged_userns_clone" = true;
      kernelModules = [ "ntsync" ];
    };

    environment.sessionVariables = {
      PROTONPATH = "${pkgs.proton-ge-bin.steamcompattool}/";
      PROTON_USE_NTSYNC = mkDefault 1;
    };

    services.udev.packages = [
      (pkgs.writeTextFile {
        name = "ntsync-udev-rules";
        text = ''KERNEL=="ntsync", MODE="0660", TAG+="uaccess"'';
        destination = "/etc/udev/rules.d/70-ntsync.rules";
      })
    ];

    hardware.steam-hardware.enable = true;
    users.users."${user}".extraGroups = [ "gamemode" ];

    environment.systemPackages = [
      (pkgs.lutris.override {
        extraPkgs = (pkgs: with pkgs; [ gamemode ]);
      })
    ];

    programs = {
      gamemode.enable = true;
      gamescope = {
        enable = true;
        package = pkgs.gamescope.overrideAttrs (old: {
          enableWsi = true;
          enableExecutable = true;
          NIX_CFLAGS_COMPILE = [ "-fno-fast-math" "-fno-omit-frame-pointer" ];
        });
        env = {
          PROTON_ENABLE_WAYLAND = "1";
        };
        args = [
          "--backend" "wayland"
          "--adaptive-sync"
          "--expose-wayland"
          "--immediate-flips"
          "--force-grab-cursor"
          "--rt"
          "-f"
          "-S" "fit"
          "-W" "2560"
          "-H" "1440"
          "-r" "360"
        ];
      };
      steam = {
        enable = true;
        package = pkgs.steam.override {
          extraPkgs = pkgs: [ pkgs.gamemode ];
        };
        remotePlay.openFirewall = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
      };
    };

    networking.hosts."0.0.0.0" = [ "ipv6check-http.steamserver.net" ];
  };
}
