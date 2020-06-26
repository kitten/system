{ pkgs-unstable, ... }:

{
  system.defaults.spaces.spans-displays = true;

  services.yabai = {
    enable = true;
    package = pkgs-unstable.yabai;
    enableScriptingAddition = true;

    config = {
      status_bar = "off";
      mouse_follows_focus = "on";
      focus_follows_mouse = "autofocus";

      window_placement = "second_child";
      window_topmost = "on";
      window_shadow = "on";

      window_border = "on";
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
      top_padding = 10;
      bottom_padding = 10;
      left_padding = 10;
      right_padding = 10;
      window_gap = 10;
    };
  };
}
