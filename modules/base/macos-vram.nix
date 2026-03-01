{ lib, config, helpers, ... }:

with lib;
let
  cfg = config.modules.vram;

  setWiredLimitMb = optionalString (cfg.wiredLimit != null) ''
    wired_memsize_mb=$(($(sysctl -n hw.memsize) / 1024 / 1024))
    sysctl -w iogpu.wired_limit_mb="$((wired_memsize_mb - ${toString (cfg.wiredLimit * 1024)}))"
  '';
  setWiredLowWaterMarkMb = optionalString (cfg.wiredLowWatermark != null) ''
    sysctl -w iogpu.wired_lwm_mb="$((${toString (cfg.wiredLowWatermark * 1024)}))"
  '';
in helpers.darwinAttrs {
  options.modules.vram = {
    wiredLimit = mkOption {
      default = null;
      description = "Wired Memory Limit in GBs";
      type = types.nullOr (types.ints.between 2 512);
    };

    wiredLowWatermark = mkOption {
      default = null;
      description = "Wired LWM (Low Watermark) in GBs";
      type = types.nullOr (types.ints.between 2 512);
    };
  };

  config = mkIf (cfg.wiredLimit != null || cfg.wiredLowWatermark != null) {
    system.activationScripts.postActivation.text = ''
      ${setWiredLimitMb}
      ${setWiredLowWaterMarkMb}
    '';

    launchd.daemons."sysctl-wired-limit" = {
      serviceConfig.RunAtLoad = true;
      script = ''
        ${setWiredLimitMb}
        ${setWiredLowWaterMarkMb}
      '';
    };
  };
}

