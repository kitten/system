{ lib, config, pkgs, helpers, ... }:

with lib;
let
  cfg = config.modules.development;
in {
  options.modules.development.cocoapods = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable Cocoapods.";
      type = types.bool;
    };
  };

  config.modules.development.cocoapods = {
    enable = if helpers.isDarwin then (mkDefault true) else (mkForce false);
  };
} // helpers.darwinAttrs {
  config = mkIf cfg.cocoapods.enable {
    environment.systemPackages = [
      pkgs.cocoapods
    ];
  };
}
