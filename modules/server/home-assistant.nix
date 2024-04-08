{ ... }:

{
  virtualisation.oci-containers = {
    backend = "podman";
    containers.hass = {
      autoStart = true;
      volumes = [
        "/var/lib/home-assistant:/config"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment.TZ = "Europe/London";
      image = "ghcr.io/home-assistant/home-assistant:stable";
      extraOptions = [
        "--device=/dev/ttyUSB0"
        "--network=host"
        "--privileged"
      ];
    };
  };
}
