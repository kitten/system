{ helpers, user, lib, ... }:

helpers.linuxAttrs {
  users.users."${user}".extraGroups = [ "video" ];

  services = {
    fwupd.enable = true;
    pipewire = {
      enable = true;
      wireplumber.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };

  hardware = {
    pulseaudio.enable = lib.mkForce false;
    steam-hardware.enable = true;
  };

  security.rtkit.enable = true;
}
