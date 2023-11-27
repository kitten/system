{ pkgs, helpers, ... }:

{
  services.mysql = {
    enable = false;
    package = pkgs.mariadb_1011;
    dataDir = "/var/lib/mysql";
    settings.mysqld = {
      bind-address = "127.0.0.1";
    };
  };
}
