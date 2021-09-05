{ pkgs, ... }:

{
  system.defaults.spaces.spans-displays = false;
  security.accessibilityPrograms = [ "${pkgs.yabai}/bin/yabai" ];

  services.yabai = {
    enable = true;
    package = pkgs.yabai;
    enableScriptingAddition = false;

    config = {
      status_bar = "off";
      mouse_follows_focus = "on";
      focus_follows_mouse = "off";

      window_placement = "second_child";
      window_topmost = "on";
      window_shadow = "on";

      window_border = "off";
      window_border_placement = "inset";
      window_border_width = 2;

      active_window_border_color = "0xff6d3ab0";
      normal_window_border_color = "0xff505050";
      insert_window_border_color = "0xffd75f5f";

      active_window_opacity = 1.0;
      normal_window_opacity = 0.9;
      split_ratio = 0.5;

      mouse_modifier = "fn";
      mouse_action1 = "move";
      mouse_action2 = "resize";

      layout = "bsp";
      top_padding = 3;
      bottom_padding = 3;
      left_padding = 4;
      right_padding = 4;
      window_gap = 4;
    };
  };
}
