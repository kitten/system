{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.development.codex;
  instructions = config.modules.development.instructions;
  toml = pkgs.formats.toml { };
in {
  options.modules.development.codex = {
    enable = mkEnableOption "the codex CLI";
    package = mkPackageOption pkgs "codex" { };
    settings = mkOption {
      type = toml.type;
      default = { };
      description = "Codex settings recursively merged with defaults. Public configuration only; credentials belong in runtime files.";
    };
  };

  config = mkIf cfg.enable {
    programs.codex = {
      enable = true;
      package = cfg.package;
      mutableSettings = true;
      settings = recursiveUpdate {
        check_for_update_on_startup = false;
      } cfg.settings;
    };
    home.file.".codex/AGENTS.md" = mkIf instructions.enable {
      source = config.lib.file.mkOutOfStoreSymlink "${config.modules.git.directory}/AGENTS.md";
    };
  };
}
