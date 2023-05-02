{ pkgs, ... }:

{
  services.mysql = {
    enable = true;
    package = pkgs.mariadb_109;
    dataDir = "/var/lib/mysql";
    settings.mysqld = {
      bind-address = "127.0.0.1";
    };
  };
}
