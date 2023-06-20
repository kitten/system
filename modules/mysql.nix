{ pkgs, helpers, ... }:

{
  services.mysql = {
    enable = helpers.isDarwin;
    package = pkgs.mariadb_1010;
    dataDir = "/var/lib/mysql";
    settings.mysqld = {
      bind-address = "127.0.0.1";
    };
  };
}
