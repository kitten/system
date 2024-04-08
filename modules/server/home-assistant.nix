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
    containers.hass = {
      autoStart = true;
      volumes = [
        "/var/lib/home-assistant:/config"
        "/etc/localtime:/etc/localtime:ro"
        "/sys:/sys:ro"
      ];
      environment.TZ = "Europe/London";
      image = "ghcr.io/home-assistant/home-assistant:stable";
      extraOptions = [
        "--userns=keep-id"
        "--hostuser=hass"
        "--runtime=runc"
        "--device=/dev/ttyUSB0"
        "--network=host"
        "--privileged"
      ];
    };
  };
}
