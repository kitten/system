{ user, ... }:

{
  users.users."${user}".extraGroups = [ "video" ];

  services.printing.enable = true;
  services.flatpak.enable = true;
}
