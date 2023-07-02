{ user, config, lib, ... }:

{
  users.users."${user}".extraGroups = [ "video" ];

  services = {
    logind.extraConfig = ''
      HandlerPowerKey=suspend
      HandleLidSwitch=suspend
    '';

    pipewire = {
      enable = true;
      wireplumber.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    gvfs.enable = true;

    blueman.enable = lib.mkIf config.hardware.bluetooth.enable true;
  };

  hardware = {
    pulseaudio.enable = lib.mkForce false;
    steam-hardware.enable = true;
  };

  security.rtkit.enable = true;
}
