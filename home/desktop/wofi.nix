{ ... }:

{
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
        background-color: --wofi-color0;
        color: --wofi-color2;
        border: 2px solid --wofi-color1;
        border-radius: 0px;
      }

      #outer-box {
        padding: 20px;
      }

      #input {
        background-color: --wofi-color1;
        border: 0px solid --wofi-color3;
        padding: 8px 12px;
      }

      #scroll {
        margin-top: 20px;
      }

      #inner-box {
      }

      #img {
        padding-right: 8px;
      }

      #text {
        color: --wofi-color2;
      }

      #text:selected {
        color: --wofi-color0;
      }

      #entry {
        padding: 6px;
      }

      #entry:selected {
        background-color: --wofi-color3;
        color: --wofi-color0;
      }

      #unselected {
      }

      #selected {
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
