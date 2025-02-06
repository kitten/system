{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.development;
in {
  options.modules.development.zig = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable Zig configuration.";
      type = types.bool;
    };
  };

  config = mkIf cfg.zig.enable {
    home.packages = with pkgs; [ zig ];
  };
}
