{ user, ... }:

{
  users.users."${user}".extraGroups = [ "video" ];

  services = {
    printing.enable = true;
    flatpak.enable = true;
    colord.enable = true;
  };
}
