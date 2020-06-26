let
  inherit (import ../../nix/channels.nix) __nixPath;
  pkgs-unstable = import <nixpkgs-unstable> {};
in {
  home.packages = [ pkgs-unstable.kitty ];

  xdg.configFile."kitty/kitty.conf".text = ''
    # See ~/nix-system/config/kitty.nix
    font_family Dank Mono Neue
    background #14161a
    color0 #191b1f
    color1 #e54b4b
    color10 #c3e88d
    color11 #ffcb6b
    color12 #82aaff
    color13 #c792ea
    color14 #89ddff
    color15 #ffffff
    color2 #9ece58
    color3 #faed70
    color4 #396fe2
    color5 #bb80b3
    color6 #2ddafd
    color7 #d0d0d0
    color8 #97a0a0
    color9 #ff5370
    cursor_blink_interval -1
    font_size 14.0
    foreground #eceff1
    hide_window_decorations yes
    scrollback_lines 0
    selection_background #ffcc00
    selection_foreground #000000
    term xterm-256color
  '';
}
