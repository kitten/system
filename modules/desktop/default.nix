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
    ./affinity.nix
    ./fonts.nix
    ./rawaccel.nix
    ./audio.nix
    ./networking.nix
    ./niri-cosmic.nix
  ];
}
