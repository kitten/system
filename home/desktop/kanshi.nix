{ ... }:

{
  services.kanshi = {
    enable = true;
    systemdTarget = "graphical-session.target";
    profiles = {
      default = {
        outputs = [
          {
            criteria = "eDP-1";
            scale = 1.44;
          }
        ];
      };
    };
  };
}
