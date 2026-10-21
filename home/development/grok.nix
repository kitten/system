{ lib, config, pkgs, osConfig, ... }:

with lib;
let
  cfg = config.modules.development.grok;
  auth = import ../../lib/shell-env-wrapper.nix { inherit lib pkgs; };
in {
  options.modules.development.grok = {
    enable = mkEnableOption "the grok CLI";
    package = mkPackageOption pkgs "grok-build" { };
    environmentFile = auth.environmentFileOptions ./encrypt/grok.env.age;
  };

  config = mkIf cfg.enable {
    home.packages = [ (auth.wrap cfg.package (auth.runtimeFiles "${config.home.username}-grok" cfg.environmentFile osConfig.age.secrets) [ "grok" "agent" ]) ];
  };
}
