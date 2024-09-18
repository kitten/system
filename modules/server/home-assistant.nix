{ lib, config, pkgs, ... }:

with lib;
let
  inherit (pkgs) stdenv;

  cfgRoot = config.modules.server;
  cfg = config.modules.server.home-assistant;

  containerImage = if stdenv.isAarch64
    then "ghcr.io/home-assistant/home-assistant:${cfg.revision}"
    else "ghcr.io/home-assistant/aarch64-home-assistant:${cfg.revision}";
in {
  options.modules.server.home-assistant = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable Home Assistant.";
      type = types.bool;
    };

    revision = mkOption {
      default = "2024.9.2";
      example = "2024.9.2";
      description = "Home Assistant Revision";
      type = types.str;
    };
  };

  config = mkIf cfg.enable && cfgRoot.enable {
    modules.server.podman.enable = mkDefault true;

    users = {
      groups.hass.gid = config.ids.gids.hass;
      users.hass = {
        uid = config.ids.uids.hass;
        group = "hass";
      };
    };

    virtualisation.oci-containers = {
      containers.hass = rec {
        autoStart = true;
        volumes = [
          "/var/lib/home-assistant:/config"
          "/etc/localtime:/etc/localtime:ro"
          "/sys:/sys:ro"
        ];
        user = "${environment.PUID}:${environment.PGID}";
        environment = {
          TZ = "Europe/London";
          PUID = "${toString config.ids.uids.hass}";
          PGID = "${toString config.ids.gids.hass}";
          UMASK = "007";
        };
        image = containerImage;
        extraOptions = [
          "--cap-drop=ALL"
          "--cap-add=CHOWN"
          "--cap-add=DAC_OVERRIDE"
          "--cap-add=FSETID"
          "--cap-add=FOWNER"
          "--cap-add=SETGID"
          "--cap-add=SETUID"
          "--cap-add=SYS_CHROOT"
          "--cap-add=KILL"
          "--cap-add=NET_RAW"
          "--cap-add=NET_ADMIN"
          "--security-opt=no-new-privileges"
          "--userns=keep-id"
          "--hostuser=hass"
          "--runtime=runc"
          "--device=/dev/ttyUSB0"
          "--network=host"
        ];
      };
    };
  };
}
