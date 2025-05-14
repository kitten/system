{ lib, pkgs, config, user, ... }:

with lib;
let
  inherit (generators) toLua;
  cfg = config.modules.desktop;
in {
  options.modules.desktop.networking = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable networking.";
      type = types.bool;
    };

    printing = mkOption {
      default = cfg.networking.enable;
      example = true;
      description = "Whether to enable printing.";
      type = types.bool;
    };
  };

  config = mkIf cfg.networking.enable {
    networking = {
      firewall = {
        enable = mkDefault true;
        checkReversePath = "loose";
        allowedUDPPorts = [ 5353 ];
      };
      nftables = {
        enable = mkForce true;
        checkRuleset = false;
        flushRuleset = true;
      };
      networkmanager = {
        enable = mkDefault true;
        dns = mkDefault (if config.servies.resolved.enable then "systemd-resolved" else "default");
        connectionConfig = {
          "connection.mdns" = mkDefault 2;
          "connection.llmnr" = 0;
        };
        wifi = {
          backend = "iwd";
          powersave = true;
        };
      };
    };

    services = {
      resolved = {
        enable = true;
        llmnr = "false";
        extraConfig = ''
          [Resolve]
          MulticastDNS=yes
        '';
      };

      printing = mkIf cfg.networking.printing {
        enable = true;
        stateless = true;
        webInterface = false;
      };
    };
  };
}
