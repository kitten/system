{ ... } @ inputs:

let
  inherit (import ../../lib/colors.nix inputs) shell colors;
in {
  programs.wofi = {
    enable = true;

    settings = {
      show = "drun";
      prompt = "Search...";
      normal_window = true;
      layer = "top";
      term = "wezterm";

      width = "500px";
      height = "305px";
      location = 0;
      orientation = "vertical";
      halign = "fill";
      line_wrap = "off";
      dynamic_lines = false;

      allow_markup = true;
      allow_images = true;
      image_size = 24;

      exec_search = false;
      hide_search = false;
      parse_search = false;
      insensitive = false;

      hide_scroll = true;
      no_actions = true;
      sort_order = "default";
      gtk_dark = true;
      filter_rate = 100;

      key_expand = "Tab";
      key_exit = "Escape";
    };

    style = ''
      * {
        font-family: "Inter", sans-serif;
        font-size: 12px;
      }

      #window {
        background: ${shell};
        color: ${colors.white.gui}
        border-radius: 14px;
        border: none;
      }

      #outer-box {
        padding: 20px;
      }

      #input {
        padding: 8px 12px;
        background: none;
        border: none;
      }

      #scroll {
        margin-top: 20px;
      }


      #img {
        padding-right: 8px;
      }

      #text {
        color: ${colors.white.gui};
      }

      #text:selected {
        color: ${colors.purple.gui};
      }

      #entry {
        padding: 6px;
      }

      #entry:selected {
        background-color: ${colors.grey.gui};
        color: ${colors.white.gui};
      }

      #input, #entry:selected {
        border-radius: 4px;
      }
    '';
  };

  xdg.configFile."wofi/colors".text = ''
    #1e1e2e
    #262636
    #d9e0ee
    #89b4fa
    #f38ba8
    #cba6f7
  '';
}
