{ user, ... }:

{
  services.logind.extraConfig = ''
    HandlerPowerKey=suspend
    HandleLidSwitch=suspend
  '';

  users.users."${user}".extraGroups = [ "video" ];

  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  security.rtkit.enable = true;
}
