{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.development;
in {
  options.modules.development.terraform = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable Terraform configuration.";
      type = types.bool;
    };
  };

  config = mkIf cfg.terraform.enable {
    home.packages = with pkgs; [ terraform ];
  };
}
