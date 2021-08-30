{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.postgresql_13
  ];

  services.postgresql = {
    enable = true;
    enableTCPIP = false;
    port = 5434;
    package = pkgs.postgresql_13;
    dataDir = "/var/lib/postgres/13";
    extraConfig = ''
      autovacuum = off
    '';
  };

  system.activationScripts.postActivation.text = ''
    if [ ! -d "/var/lib/postgres" ]; then
     mkdir -p "/var/lib/postgres"
     chmod -R 777 "/var/lib/postgres"
    fi
  '';
}
