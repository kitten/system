{ pkgs, ... }:

{
  home.packages = [ pkgs.rofi-rbw ];

  programs.rbw = {
    enable = true;
    settings = {
      email = "phil@kitten.sh";
      base_url = "https://vault.kitten.sh";
      pinentry = "gnome3";
    };
  };

  xdg.configFile."rofi-rbw.rc".text = ''
    action=copy
    selector=wofi
    clear-after=120
  '';
}
