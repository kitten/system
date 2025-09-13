{ lib, config, ... }:

with lib;
let
  cfg = config.modules.automation;

  frontendType = types.submodule {
    options = {
      enable = mkOption {
        default = false;
        example = true;
        description = "Whether to enable Zigbee2MQTT's frontend.";
        type = types.bool;
      };
      port = mkOption {
        default = 8124;
        example = 8124;
        description = "The port to use for Zigbee2MQTT's frontend.";
        type = types.port;
      };
    };
  };
in {
  options.modules.automation.zigbee = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable the Zigbee2MQTT service.";
      type = types.bool;
    };

    permitJoin = mkOption {
      default = false;
      description = "Permit new devices to join indefinitely (Not Recommended)";
      type = types.bool;
    };

    serialPort = mkOption {
      default = "/dev/ttyUSB0";
      example = "/dev/ttyUSB0";
      description = "The serial port for the USB Zigbee adapter.";
      type = types.str;
    };

    frontend = mkOption {
      default = {};
      description = "Zigbee2MQTT's frontend options.";
      type = frontendType;
    };
  };

  config = mkIf (cfg.enable && cfg.zigbee.enable) {
    users.users.zigbee2mqtt.extraGroups = mkIf cfg.mqtt.enable [
      config.users.users.mosquitto.name
    ];

    services.zigbee2mqtt = {
      enable = true;
      settings = {
        permit_join = cfg.zigbee.permitJoin;
        serial = {
          adapter = "zstack";
          port = cfg.zigbee.serialPort;
        };
        frontend = if cfg.zigbee.frontend.enable then cfg.zigbee.frontend else false;
        ota.disable_automatic_update_check = true;
        mqtt = mkIf cfg.mqtt.enable {
          server = "mqtts://localhost:${toString cfg.mqtt.port}";
          reject_unauthorized = false;
          ca = cfg.mqtt.cafile;
          key = cfg.mqtt.keyfile;
          cert = cfg.mqtt.certfile;
        };
        advanced = {
          log_level = "warning";
          log_output = ["console"];
        };
      };
    };

    systemd.services.zigbee2mqtt = mkIf cfg.mqtt.enable {
      wants = [config.systemd.services.mosquitto.name];
      after = [config.systemd.services.mosquitto.name];
    };
  };
}
