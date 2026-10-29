{ lib, config, ... }:

with lib;
let
  cfg = config.modules.development.instructions;
in {
  options.modules.development.instructions = {
    enable = mkOption {
      type = types.bool;
      default = config.modules.development.enable;
      description = "Whether to install shared personal agent instructions.";
    };

    extra = mkOption {
      type = types.lines;
      default = "";
      description = "Additional instructions for this account. Public text only; stored in the Nix store.";
    };

    text = mkOption {
      type = types.lines;
      readOnly = true;
      default = builtins.readFile ./agents/AGENTS.md + optionalString (cfg.extra != "") ("\n" + cfg.extra + "\n");
      description = "Shared personal instructions, including account-specific additions.";
    };
  };

  config = mkIf cfg.enable {
    home.file."${config.modules.git.directory}/AGENTS.md".text = cfg.text;
  };
}
