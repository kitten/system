{ pkgs, ... }:

let
  colors = import ../colors.nix;
in {
  home.packages = [ pkgs.kitty ];

  xdg.configFile."kitty/kitty.conf".text = ''
    # See ~/nix-system/config/kitty.nix
    shell ${pkgs.zsh}/bin/zsh
    font_family Dank Mono
    symbol_map U+ea60-U+ebd1 codicon
    ${colors.kitty}
    cursor_blink_interval -1
    font_size 14.0
    hide_window_decorations yes
    scrollback_lines 0
    term xterm-256color
    clipboard_control write-clipboard write-primary no-append
  '';
}
