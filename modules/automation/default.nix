{ lib, helpers, ... }:

with lib; {
  options.modules.automation = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable Home Automation options.";
      type = types.bool;
    };
  };

  config.modules.automation = {
    enable = if helpers.isLinux then (mkDefault false) else (mkForce false);
  };
} // helpers.linuxAttrs {
  imports = [
    ./mqtt.nix
    ./zigbee.nix
    ./homebridge
  ];
}
