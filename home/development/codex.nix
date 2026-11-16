{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.development;
  instructions = config.modules.development.instructions;
  toml = pkgs.formats.toml { };
  auth = import ../../lib/shell-env-wrapper.nix { inherit lib pkgs; };
in {
  options.modules.development.codex = {
    enable = mkOption {
      default = cfg.js.enable || cfg.react-native.enable;
      example = true;
      description = "Whether to enable Codex configuration.";
      type = types.bool;
    };

    package = mkPackageOption pkgs "codex" { };
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ pkgs.linn ];
      defaultText = literalExpression "[ pkgs.linn ]";
      description = "Packages added to Codex's PATH.";
    };
    settings = mkOption {
      type = toml.type;
      default = { };
      description = "Codex settings recursively merged with defaults. Public configuration only; credentials belong in runtime files.";
    };
  };

  config = mkIf cfg.codex.enable {
    programs.codex = {
      enable = true;
      package = auth.wrapWithArgs cfg.codex.package [ "--prefix" "PATH" ":" (makeBinPath cfg.codex.extraPackages) ] [ "codex" ];
      mutableSettings = true;
      settings = recursiveUpdate {
        check_for_update_on_startup = false;
        features.memories = false;
        features.external_agent_memory_import = false;
        memories = {
          generate_memories = false;
          use_memories = false;
        };
      } cfg.codex.settings;
    };
    home.file.".codex/AGENTS.md" = mkIf instructions.enable {
      source = config.lib.file.mkOutOfStoreSymlink "${config.modules.git.directory}/AGENTS.md";
    };
  };
}
