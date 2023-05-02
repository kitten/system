{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.postgresql_13
  ];

  services.postgresql = {
    enable = false;
    enableTCPIP = false;
    port = 5434;
    package = pkgs.postgresql_13;
    dataDir = "/var/lib/postgres/13";
    extraConfig = ''
      autovacuum = off
    '';
  };
}
