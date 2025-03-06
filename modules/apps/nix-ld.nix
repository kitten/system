{ lib, config, helpers, ... }:

with lib;
let
  cfg = config.modules.apps;
in {
  options.modules.apps.nix-ld = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable nix-ld configuration.";
      type = types.bool;
    };
  };

  config.modules.apps.nix-ld = {
    enable = if helpers.isLinux then (mkDefault true) else (mkForce false);
  };
} // helpers.linuxAttrs {
  config = mkIf (cfg.enable && cfg.nix-ld.enable) {
    programs.nix-ld.enable = true;
  };
}
