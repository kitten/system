{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop;

  concat = concatMapStringsSep "," toString;
  performance = concat cfg.affinity.performanceCores;
  efficiency = concat cfg.affinity.efficiencyCores;
in {
  options.modules.desktop.affinity = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Tweak CPU affinity into performance and efficiency core slices";
      type = types.bool;
    };

    oomd = mkOption {
      default = false;
      example = true;
      description = "Enable systemd-oomd";
      type = types.bool;
    };

    performanceCores = mkOption {
      type = with types; listOf ints.unsigned;
      default = [ ];
      description = "List of performance CPUs";
    };

    efficiencyCores = mkOption {
      type = with types; listOf ints.unsigned;
      default = [ 0 1 2 3 ];
      description = "List of efficiency CPUs";
    };

    isolateNixDaemon = mkOption {
      default = cfg.affinity.enable;
      type = types.bool;
    };
  };

  config = mkIf cfg.affinity.enable {
    boot.kernelParams = [ "rcu_nocbs=all" ]
      ++ optionals (efficiency != "") [ "irqaffinity=${efficiency}" ]
      ++ optionals (performance != "") [ "nohz_full=${performance}" ];

    systemd = {
      oomd.enable = false;
      user.slices = {
        background.sliceConfig = {
          AllowedCPUs = efficiency;
          CPUWeight = 80;
          IOWeight = 60;
        };
        session.sliceConfig = {
          StartupAllowedCPUs = mkIf (performance != "") "${efficiency},${performance}";
          AllowedCPUs = efficiency;
          IOWeight = 90;
        };
        app.sliceConfig.IOWeight = 100;
      };
      slices = {
        system.sliceConfig = {
          AllowedCPUs = efficiency;
          IOWeight = 120;
        };
        nix.sliceConfig = mkIf cfg.affinity.isolateNixDaemon {
          CPUQuota = "80%";
          IOWeight = 90;
        };
      };
      services = {
        nix-daemon.serviceConfig = mkIf cfg.affinity.isolateNixDaemon {
          Slice = "nix.slice";
          OOMScoreAdjust = 950;
        };
        "user@" = {
          overrideStrategy = "asDropin";
          serviceConfig.Delegate = "cpuset";
        };
      };
    };

    assertions = singleton {
      assertion = mutuallyExclusive cfg.affinity.performanceCores cfg.affinity.efficiencyCores;
      message = "Performance and efficiency CPU cores must not overlap";
    };
  };
}
