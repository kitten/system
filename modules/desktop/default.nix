{ lib, config, user, helpers, ... }:

with lib;
let
  cfg = config.modules.desktop;
in {
  options.modules.desktop = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable Desktop options.";
      type = types.bool;
    };
  };

  config.modules.desktop = {
    enable = if helpers.isLinux then (mkDefault false) else (mkForce false);
  };
} // helpers.linuxAttrs {
  imports = [
    ./services.nix
    ./session.nix
    ./xdg.nix
    ./fonts.nix
  ];

  config = mkIf cfg.enable {
    users.users."${user}".extraGroups = [ "video" ];

    networking.networkmanager = {
      enable = mkDefault true;
      wifi.powersave = true;
    };

    services = {
      fwupd.enable = true;
      pipewire = {
        enable = true;
        wireplumber.enable = true;
        pulse.enable = true;
        jack.enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
      };
    };

    hardware = {
      pulseaudio.enable = lib.mkForce false;
      steam-hardware.enable = true;
    };

    security.rtkit.enable = true;
  };
}
