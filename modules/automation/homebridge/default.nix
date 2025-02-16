{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.automation;

  format = pkgs.formats.json { };
  configFile = format.generate "zigbee2mqtt.yaml" cfg.homebridge.settings;

  packageJson = builtins.fromJSON (builtins.readFile ./package.json);
  pluginsDefault = lists.remove "homebridge" (attrNames packageJson.dependencies);

  homebridge-distribution = pkgs.stdenvNoCC.mkDerivation rec {
    name = "homebridge-distribution";
    src = ./.;
    offlineCache = pkgs.fetchYarnDeps {
      yarnLock = src + "/yarn.lock";
      hash = "sha256-a4zkEr/v6ZBTXS6Q5oij5G0zsGh1QCGa8/5Do0C/inM=";
    };
    strictDeps = true;
    nativeBuildInputs = with pkgs; [
      yarnConfigHook
      yarnInstallHook
      nodejs
    ];
  };

  defaultConfigPlatform = {
    platform = "config";
    name = "Config";
    auth = "none";
    port = cfg.homebridge.frontend.port;
    disableServerMetricsMonitoring = true;
    homebridgePackagePath = "${cfg.homebridge.userStoragePath}/node_modules/homebridge";
    standalone = true;
    sudo = false;
    log = {
      method = "systemd";
      service = "homebridge";
    };
  };

  defaultServiceConfig = {
    Type = "simple";
    User = "homebridge";
    Group = "homebridge";
    PermissionsStartOnly = true;
    WorkingDirectory = cfg.homebridge.userStoragePath;
    Restart = "always";
    RestartSec = 3;
    KillMode = "process";
    CapabilityBoundingSet = [ "CAP_IPC_LOCK" "CAP_NET_ADMIN" "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" "CAP_SETGID" "CAP_SETUID" "CAP_SYS_CHROOT" "CAP_CHOWN" "CAP_FOWNER" "CAP_DAC_OVERRIDE" "CAP_AUDIT_WRITE" "CAP_SYS_ADMIN" ];
    AmbientCapabilities = [ "CAP_NET_RAW" "CAP_NET_BIND_SERVICE" ];
  };

  defaultArgs = [
    "-U ${cfg.homebridge.userStoragePath}"
    "-P ${cfg.homebridge.pluginPath}"
    "--strict-plugin-resolution"
  ] ++ optionals cfg.homebridge.frontend.enable ["-I"];

  frontendType = types.submodule {
    options = {
      enable = mkOption {
        default = false;
        example = true;
        description = "Whether to enable Homebridge's frontend.";
        type = types.bool;
      };
      port = mkOption {
        default = 8125;
        example = 8125;
        description = "The port to use for Homebridge's frontend.";
        type = types.port;
      };
    };
  };

  bridgeType = types.submodule {
    options = {
      name = mkOption {
        default = "Homebridge";
        example = "Homebridge name";
        type = types.str;
      };
      username = mkOption {
        default = "CC:22:3D:E3:CE:30";
        type = types.str;
      };
      pin = mkOption {
        default = "031-45-154";
        type = types.str;
      };
      port = mkOption {
        default = 51826;
        type = types.port;
      };
      advertiser = mkOption {
        default = if config.services.resolved.enable then "resolved" else "ciao";
        type = types.str;
      };
      bind = mkOption {
        default = lists.remove "lo" config.networking.firewall.trustedInterfaces;
        type = types.listOf types.str;
      };
    };
  };
in {
  options.modules.automation.homebridge = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable Homebridge service.";
      type = types.bool;
    };

    plugins = mkOption {
      default = pluginsDefault;
      description = "Names of package installed in the homebridge-distribution.";
      type = types.listOf types.str;
    };

    frontend = mkOption {
      default = {};
      type = frontendType;
    };

    bridge = mkOption {
      default = {};
      type = bridgeType;
    };

    settings = mkOption {
      type = format.type;
      default = { };
    };

    userStoragePath = mkOption {
      default = "/var/lib/homebridge";
      description = "Path to store homebridge user files (needs to be writeable).";
      type = types.str;
    };

    pluginPath = mkOption {
      default = "${cfg.homebridge.userStoragePath}/node_modules";
      type = types.str;
    };
  };

  config = mkIf (cfg.enable && cfg.homebridge.enable) {
    modules.automation.homebridge.settings = {
      description = mkDefault "Homebridge";
      bridge = mkForce cfg.homebridge.bridge;
      platforms = [defaultConfigPlatform]
        ++ optionals (cfg.zigbee.enable && cfg.mqtt.enable) [
          {
            platform = "zigbee2mqtt";
            mqtt = {
              base_topic = "zigbee2mqtt";
              server = "mqtts://localhost:${toString cfg.mqtt.port}";
              disable_qos = true;
              reject_unauthorized = false;
              ca = cfg.mqtt.cafile;
              key = cfg.mqtt.keyfile;
              cert = cfg.mqtt.certfile;
            };
            defaults.exclude = false;
            exclude_grouped_devices = false;
          }
        ];
    };

    systemd.services.homebridge = {
      description = "Homebridge";
      after = [ "syslog.target" "network.target" ]
        ++ optionals cfg.mqtt.enable [config.systemd.services.mosquitto.name];
      wants = optionals cfg.mqtt.enable [config.systemd.services.mosquitto.name];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = let
        args = concatStringsSep " " defaultArgs;
      in defaultServiceConfig // {
        ExecStart = "${homebridge-distribution}/bin/homebridge ${args}";
      };

      preStart = let
        inherit (cfg.homebridge) pluginPath userStoragePath plugins;
        lnPlugins = concatStringsSep "\n" (map
          (name: ''
            ln -fns "${homebridge-distribution}/lib/node_modules/homebridge-distribution/node_modules/${name}" "${pluginPath}/${name}"
          '')
          plugins);
      in ''
        mkdir -p ${pluginPath}
        ${lnPlugins}
        cp --no-preserve=mode ${configFile} "${userStoragePath}/config.json"
        chown homebridge "${userStoragePath}/config.json" "${pluginPath}"
        chgrp homebridge "${userStoragePath}/config.json" "${pluginPath}"
      '';
    };

    systemd.services.homebridge-frontend = mkIf cfg.homebridge.frontend.enable {
      description = "Homebridge Frontend";
      after = [ "syslog.target" "network.target" config.systemd.services.homebridge.name ];
      requires = [ config.systemd.services.homebridge.name ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [
        nodejs_20
        nettools
        gcc
        gnumake
        systemd
        "/run/wrappers"
      ];

      environment = {
        HOMEBRIDGE_CONFIG_UI_TERMINAL = "1";
        DISABLE_OPENCOLLECTIVE = "true";
        UIX_STRICT_PLUGIN_RESOLUTION = "1";
      };

      serviceConfig = let
        args = concatStringsSep " " defaultArgs;
      in defaultServiceConfig // {
        ExecStart = "${homebridge-distribution}/bin/homebridge-config-ui ${args}";
      };
    };

    users = {
      groups.homebridge = {};
      users.homebridge = {
        home = cfg.homebridge.userStoragePath;
        createHome = true;
        group = "homebridge";
        extraGroups = [ "systemd-journal" ] ++ optionals cfg.mqtt.enable [config.users.users.mosquitto.name];
        isSystemUser = true;
      };
    };

    security.polkit.extraConfig = optionalString (cfg.homebridge.bridge.advertiser == "resolved") ''
      // kitten/system: Allow homebridge to register systemd-resolved services
      // This was enabled via modules.automation.homebridge
      polkit.addRule(function(action, subject) {
        if ((action.id == "org.freedesktop.resolve1.register-service" ||
          action.id == "org.freedesktop.resolve1.unregister-service") &&
          subject.user == "${config.users.users.homebridge.name}") {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
