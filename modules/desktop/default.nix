{ lib, config, user, helpers, ... }:

with lib;
let
  cfg = config.modules.desktop;
in {
  options.modules.desktop = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable Desktop options.";
      type = types.bool;
    };
  };

  config.modules.desktop = {
    enable = if helpers.isLinux then (mkDefault false) else (mkForce false);
  };
} // helpers.linuxAttrs {
  imports = [
    ./services.nix
    ./session.nix
    ./affinity.nix
    ./fonts.nix
    ./rawaccel.nix
  ];

  config = mkIf cfg.enable {
    users.users."${user}".extraGroups = [ "video" ];

    networking = {
      firewall = {
        enable = mkDefault true;
        checkReversePath = "loose";
      };
      nftables = {
        enable = mkForce true;
        checkRuleset = false;
        flushRuleset = true;
      };
      networkmanager = {
        enable = mkDefault true;
        wifi = {
          backend = "iwd";
          powersave = true;
        };
      };
    };

    hardware = {
      steam-hardware.enable = true;
    };

    security.rtkit.enable = true;
  };
}
