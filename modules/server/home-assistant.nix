{ config, ... }:

{
  users = {
    groups.hass.gid = config.ids.gids.hass;
    users.hass = {
      uid = config.ids.uids.hass;
      group = "hass";
    };
  };

  virtualisation.oci-containers = {
    backend = "podman";
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
      image = "ghcr.io/home-assistant/home-assistant:stable";
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
}
