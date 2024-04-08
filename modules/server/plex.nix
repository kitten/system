{ user, ... }:

{
  users.users."${user}".extraGroups = [ "share" ];

  users.groups = {
    share.gid = 1001;
  };

  services.plex = {
    enable = true;
    openFirewall = false;
    group = "share";
  };
}
