{ lib, helpers, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.development;
in {
  options.modules.development.react-native = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable React Native configuration.";
      type = types.bool;
    };
  };

  config.modules.apps.firefox = {
    enable = if helpers.isDarwin then (mkDefault true) else (mkForce false);
  };
} // helpers.darwinAttrs {
  config = mkIf (cfg.enable && cfg.react-native.enable) {
    home.packages = with pkgs; [ cocoapods ];
  };
}
