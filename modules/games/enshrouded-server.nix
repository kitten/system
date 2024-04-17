{ lib, config, pkgs, ... }:

{
  ids.gids.steam = lib.mkDefault 10000;
  ids.uids.steam = lib.mkDefault 10000;

  users = {
    groups.steam.gid = config.ids.gids.steam;
    users.steam = {
      uid = config.ids.uids.steam;
      group = "steam";
      createHome = true;
      home = "/var/lib/steam";
      isSystemUser = true;
    };
  };

  virtualisation.oci-containers = {
    containers.enshrouded = rec {
      autoStart = false;
      volumes = [
        "/var/lib/steam/enshrouded:/home/steam/enshrouded/savegame"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = {
        TZ = "Europe/London";
        SERVER_IP = "0.0.0.0";
        SERVER_NAME = "London Boroughs";
        SERVER_PASSWORD = "deepdickgalactic";
        GAME_PORT = "15636";
        QUERY_PORT = "15637";
        SERVER_SLOTS = "8";
      };
      image = "docker.io/sknnr/enshrouded-dedicated-server:proton-latest";
      ports = [
        "15636:15636/udp"
        "15637:15637/udp"
      ];
      extraOptions = [
        "--userns=keep-id"
        "--cap-add=NET_RAW"
        "--runtime=runc"
      ];
    };
  };

  networking.firewall.allowedUDPPorts = [
    15636
    15637
  ];
}
