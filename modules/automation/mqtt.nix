{ lib, config, ... }:

with lib;
let
  cfg = config.modules.automation;
in {
  options.modules.automation.mqtt = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable the MQTT Mosquitto broker.";
      type = types.bool;
    };

    port = mkOption {
      default = 1883;
      example = 1883;
      description = "The port to start Moquitto on.";
      type = types.port;
    };

    cafile = mkOption {
      default = ../base/certs/ca.crt;
      type = types.path;
    };

    certfile = mkOption {
      default = config.age.secrets."mqtt.crt".path;
      type = types.path;
    };

    keyfile = mkOption {
      default = config.age.secrets."mqtt.key".path;
      type = types.path;
    };
  };

  config = mkIf cfg.mqtt.enable {
    age.secrets = let
      owner = config.users.users.mosquitto.name;
      group = config.users.users.mosquitto.group;
      mode = "0440";
    in {
      "mqtt.crt" = {
        inherit owner group mode;
        file = ./certs/mqtt.crt.age;
      };
      "mqtt.key" = {
        inherit owner group mode;
        file = ./certs/mqtt.key.age;
      };
    };

    services.mosquitto = {
      enable = true;
      listeners = [
        {
          port = cfg.mqtt.port;
          omitPasswordAuth = true;
          settings = {
            cafile = cfg.mqtt.cafile;
            certfile = cfg.mqtt.certfile;
            keyfile = cfg.mqtt.keyfile;
            require_certificate = true;
            allow_anonymous = true;
          };
        }
      ];
    };
  };
}
