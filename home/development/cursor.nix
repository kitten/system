{ lib, config, pkgs, osConfig, ... }:

with lib;
let
  cfg = config.modules.development.cursor;
  auth = import ../../lib/shell-env-wrapper.nix { inherit lib pkgs; };
in {
  options.modules.development.cursor = {
    enable = mkEnableOption "the cursor CLI";
    package = mkPackageOption pkgs "cursor-cli" { };
    environmentFile = auth.environmentFileOptions ./encrypt/cursor.env.age;
  };

  config = mkIf cfg.enable {
    home.packages = [ (auth.wrap cfg.package (auth.runtimeFiles "${config.home.username}-cursor" cfg.environmentFile osConfig.age.secrets) [ "cursor-agent" ]) ];
  };
}
