{ pkgs-unstable, ... }:

{
  security.accessibilityPrograms = [ "${pkgs-unstable.skhd}/bin/skhd" ];

  services.skhd = {
    enable = true;
    package = pkgs-unstable.skhd;

    skhdConfig = ''
      :: default  : yabai -m config status_bar_background_color 0xff191b1f;\
                    yabai -m config active_window_border_color  0xff6d3ab0;\
                    yabai -m config normal_window_border_color  0xff505050;\
                    yabai -m config window_border_width         2
      :: screen @ : yabai -m config status_bar_background_color 0xffd14783;\
                    yabai -m config active_window_border_color  0xffd14783;\
                    yabai -m config normal_window_border_color  0xffd14783;\
                    yabai -m config window_border_width         3

      default < ctrl - s ; screen
      screen  < ctrl - s ; default
      screen  < ctrl - c ; default
      screen  < escape   ; default

      screen < h : yabai -m window --focus west  ; skhd -k 'escape'
      screen < j : yabai -m window --focus south ; skhd -k 'escape'
      screen < k : yabai -m window --focus north ; skhd -k 'escape'
      screen < l : yabai -m window --focus east  ; skhd -k 'escape'

      default < cmd + shift - h : yabai -m window --focus west
      default < cmd + shift - j : yabai -m window --focus south
      default < cmd + shift - k : yabai -m window --focus north
      default < cmd + shift - l : yabai -m window --focus east

      default < 0x0A : skhd -k 'escape'

      screen < x : yabai -m space --destroy ; skhd -k 'escape'
      screen < c : yabai -m space --create  ; skhd -k 'escape'

      screen < ctrl - h : yabai -m window --swap west
      screen < ctrl - j : yabai -m window --swap south
      screen < ctrl - k : yabai -m window --swap north
      screen < ctrl - l : yabai -m window --swap east

      screen < cmd - h : yabai -m space --focus prev   ; skhd -k 'escape'
      screen < cmd - j : yabai -m display --focus prev ; skhd -k 'escape'
      screen < cmd - k : yabai -m display --focus next ; skhd -k 'escape'
      screen < cmd - l : yabai -m space --focus next   ; skhd -k 'escape'

      default < cmd + ctrl - h : yabai -m space --focus prev
      default < cmd + ctrl - j : yabai -m display --focus prev
      default < cmd + ctrl - k : yabai -m display --focus next
      default < cmd + ctrl - l : yabai -m space --focus next

      screen < shift - h : yabai -m window --space prev; yabai -m space --focus prev
      screen < shift - j : yabai -m window --display prev; yabai -m display --focus prev
      screen < shift - k : yabai -m window --display next; yabai -m display --focus next
      screen < shift - l : yabai -m window --space next; yabai -m space --focus next

      screen < 1 : yabai -m space --focus 1  ; skhd -k 'escape'
      screen < 2 : yabai -m space --focus 2  ; skhd -k 'escape'
      screen < 3 : yabai -m space --focus 3  ; skhd -k 'escape'
      screen < 4 : yabai -m space --focus 4  ; skhd -k 'escape'
      screen < 5 : yabai -m space --focus 5  ; skhd -k 'escape'
      screen < 6 : yabai -m space --focus 6  ; skhd -k 'escape'
      screen < 7 : yabai -m space --focus 7  ; skhd -k 'escape'
      screen < 8 : yabai -m space --focus 8  ; skhd -k 'escape'
      screen < 9 : yabai -m space --focus 9  ; skhd -k 'escape'
      screen < 0 : yabai -m space --focus 10 ; skhd -k 'escape'

      screen < r       : yabai -m space --rotate 90
      screen < f       : yabai -m window --toggle zoom-fullscreen
      screen < s       : yabai -m window --toggle sticky
      screen < cmd - f : yabai -m window --toggle native-fullscreen

      screen < p : yabai -m window --toggle sticky;\
                   yabai -m window --toggle topmost;\
                   yabai -m window --grid 5:5:4:0:1:1
    '';
  };
}

