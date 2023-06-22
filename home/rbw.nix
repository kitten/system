{ pkgs, helpers, ... }:

{
  programs.rbw = {
    enable = true;
    settings = {
      email = "phil@kitten.sh";
      base_url = "https://vault.kitten.sh";
      pinentry = if helpers.isDarwin then "curses" else "gnome3";
    };
  };

  xdg.configFile."rofi-rbw.rc".text = ''
    action=copy
    selector=wofi
    clear-after=120
  '';
}
