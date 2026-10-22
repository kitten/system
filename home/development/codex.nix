{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.development.codex;
in {
  options.modules.development.codex = {
    enable = mkEnableOption "the codex CLI";
    package = mkPackageOption pkgs "codex" { };
  };

  config = mkIf cfg.enable {
    programs.codex = {
      enable = true;
      package = cfg.package;
    };
  };
}
