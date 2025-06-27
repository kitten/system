{ lib, config, user, helpers, ... }:

with lib;
let
  cfg = config.modules.server;
in helpers.darwinAttrs {
  options.modules.server = {
    disableSleep = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to disable sleep";
      type = types.bool;
    };
  };

  config = mkIf cfg.disableSleep {
    system.activationScripts.postActivation.text = ''
      defaults write com.apple.screensaver idleTime 0
      pmset -a powernap 0
      pmset -a sms 0
      pmset -a sleep 0
      pmset -a hibernatemode 0
      pmset -a disablesleep 1
    '';

    power = {
      restartAfterFreeze = true;
      sleep = {
        allowSleepByPowerButton = false;
        computer = "never";
      };
    };
  };
}
