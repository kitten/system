{ lib, config, helpers, pkgs, ... } @ inputs:

with lib;
let
  inherit (import ../../lib/colors.nix inputs) hex;

  cfg = config.modules.apps;
in {
  options.modules.apps.ghostty = {
    enable = mkOption {
      default = false;
      description = "Whether to enable Ghostty.";
      type = types.bool;
    };

    font_size = mkOption {
      default = if helpers.isDarwin then 14 else 12;
      type = types.int;
    };

    cell_adjust = mkOption {
      default = if helpers.isDarwin then -1 else 0;
      type = types.int;
    };
  };

  config = mkIf (cfg.enable && cfg.ghostty.enable) (mkMerge [
    (helpers.mkIfLinux {
      home.packages = [pkgs.ghostty];
    })

    {
      xdg.configFile."ghostty/config".text = ''
        font-family = Dank Mono
        font-family = codicon
        font-size = ${toString cfg.ghostty.font_size}
        bold-is-bright = false

        background = ${hex.black}
        foreground = ${hex.white}

        palette = 0=${hex.black}
        palette = 1=${hex.red}
        palette = 2=${hex.green}
        palette = 3=${hex.yellow}
        palette = 4=${hex.blue}
        palette = 5=${hex.magenta}
        palette = 6=${hex.aqua}
        palette = 7=${hex.white}
        palette = 8=${hex.grey}
        palette = 9=${hex.brightRed}
        palette = 10=${hex.brightGreen}
        palette = 11=${hex.orange}
        palette = 12=${hex.brightBlue}
        palette = 13=${hex.pink}
        palette = 14=${hex.cyan}
        palette = 15=${hex.muted}

        split-divider-color = ${hex.split}
        cursor-color = ${hex.white}
        cursor-style = block
        cursor-style-blink = false
        cursor-text = ${hex.grey}
        cursor-opacity = 0.8
        adjust-cursor-thickness = 1

        adjust-cell-width = ${toString cfg.ghostty.cell_adjust}
        window-padding-x = 2
        window-padding-y = 3
        window-padding-balance = true
        window-padding-color = extend
        window-theme = ghostty
        window-colorspace = display-p3
        window-save-state = always
        window-decoration = server
        unfocused-split-opacity = 0.9

        adjust-underline-thickness = -1
        adjust-underline-position = 1

        copy-on-select = false
        confirm-close-surface = false
        quit-after-last-window-closed = true

        macos-option-as-alt = left
        macos-titlebar-style = tabs

        adw-toolbar-style = flat

        shell-integration-features = no-cursor,sudo,title
        shell-integration = zsh

        mouse-hide-while-typing = true
        mouse-shift-capture = true
        mouse-scroll-multiplier = 0.7

        clipboard-read = allow
        clipboard-paste-protection = false

        quick-terminal-position = bottom

        keybind = clear
        keybind = super+q=quit
        keybind = super+w=close_surface
        keybind = super+a=select_all
        keybind = super+h=toggle_visibility

        keybind= super+zero=reset_font_size
        keybind= super+equal=increase_font_size:2
        keybind= super+plus=increase_font_size:2
        keybind= super+minus=decrease_font_size:2

        keybind = ctrl+a>z=toggle_split_zoom
        keybind = ctrl+a>x=close_surface
        keybind = ctrl+a>i=inspector:toggle
        keybind = ctrl+a>f=toggle_fullscreen
        keybind = ctrl+a>q=toggle_quick_terminal
        keybind = ctrl+a>space=jump_to_prompt:1

        keybind = ctrl+a>shift+five=new_split:right
        keybind = ctrl+a>shift+apostrophe=new_split:down
        keybind = ctrl+a>d=new_split:right
        keybind = ctrl+a>s=new_split:down

        keybind = ctrl+a>n=next_tab
        keybind = ctrl+a>p=previous_tab
        keybind = ctrl+a>c=new_tab
        keybind = ctrl+a>o=toggle_tab_overview
        keybind = ctrl+a>shift+n=move_tab:1
        keybind = ctrl+a>shift+p=move_tab:-1

        keybind = ctrl+h=goto_split:left
        keybind = ctrl+j=goto_split:bottom
        keybind = ctrl+k=goto_split:top
        keybind = ctrl+l=goto_split:right

        keybind = ctrl+a>h=resize_split:left,40
        keybind = ctrl+a>j=resize_split:down,40
        keybind = ctrl+a>k=resize_split:up,40
        keybind = ctrl+a>l=resize_split:right,40
        keybind = ctrl+a>g=equalize_splits

        keybind = performable:super+c=copy_to_clipboard
        keybind = performable:super+v=paste_from_clipboard

        keybind = global:cmd+grave_accent=toggle_quick_terminal
      '';
    }
  ]);
}
