{ lib, config, ... }:

with lib;
let
  cfg = config.modules.automation;
in {
  options.modules.automation.mqtt = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable the mqtt mosquitto broker.";
      type = types.bool;
    };
  };

  config = mkIf cfg.mqtt.enable {
    age.secrets = let
      owner = config.users.users.mosquitto.name;
      group = config.users.users.mosquitto.group;
    in {
      "mqtt.crt" = {
        inherit owner group;
        file = ./certs/mqtt.crt.age;
      };
      "mqtt.key" = {
        inherit owner group;
        file = ./certs/mqtt.key.age;
      };
    };

    services.mosquitto = {
      enable = true;
      listeners = [
        {
          port = 1883;
          settings = {
            cafile = ../base/certs/ca.crt;
            certfile = config.age.secrets."mqtt.crt".path;
            keyfile = config.age.secrets."mqtt.key".path;
            require_certificate = true;
          };
        }
      ];
    };
  };
}
