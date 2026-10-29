{ lib, config, pkgs, osConfig, ... }:

with lib;
let
  cfg = config.modules.development.grok;
  auth = import ../../lib/shell-env-wrapper.nix { inherit lib pkgs; };
  instructions = config.modules.development.instructions;
  toml = pkgs.formats.toml { };
  settings = recursiveUpdate {
    cli.auto_update = false;
    features = {
      telemetry = false;
      feedback = false;
    };
  } cfg.settings;
in {
  options.modules.development.grok = {
    enable = mkEnableOption "the grok CLI";
    package = mkPackageOption pkgs "grok-build" { };
    environmentFile = auth.environmentFileOptions ./encrypt/grok.env.age;
    settings = mkOption {
      type = toml.type;
      default = { };
      description = "Grok managed settings recursively merged with defaults. Public configuration only; use environmentFile for credentials.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ (auth.wrap cfg.package (auth.runtimeFiles "${config.home.username}-grok" cfg.environmentFile osConfig.age.secrets) [ "grok" "agent" ]) ];
    home.file = {
      ".grok/AGENTS.md" = mkIf instructions.enable {
        source = config.lib.file.mkOutOfStoreSymlink "${config.modules.git.directory}/AGENTS.md";
      };
      ".grok/managed_config.toml".source = toml.generate "grok-managed-config.toml" settings;
    };
    assertions = [{
      assertion = !instructions.enable || stringLength instructions.text <= 10000;
      message = "Grok truncates instructions at 10,000 characters; shorten the shared instructions or this account's extra text.";
    }];
  };
}
