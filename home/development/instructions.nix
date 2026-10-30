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

    authorizedGitKeys = mkOption {
      type = types.listOf types.str;
      default = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJffcTjACQ0XJLO7iv16MVgM783KAn1q1LsaIT/kWqNn phil+agent@kitten.sh"
      ];
      description = ''
        Public SSH keys granted Git-only access when shared instructions are enabled.
        Independent of agent account enablement. Set to an empty list to opt out.
      '';
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
    modules.git.sshAccess = {
      enable = mkDefault true;
      authorizedKeys = cfg.authorizedGitKeys;
    };
    home.file."${config.modules.git.directory}/AGENTS.md".text = cfg.text;
  };
}
