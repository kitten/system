{ lib, config, pkgs, ... } @ args:

with lib;
let
  isEnabled = config.modules.games.enable && config.modules.games.palworld.enable;
  baseCfg = config.modules.games;
  cfg = config.modules.games.palworld;

  name = "palworld-server";
  scripts = (import ../lib/scripts.nix) args;

  generateSettings = name: value: let
    optionSettings =
      mapAttrsToList
      (optName: optVal: let
        optType = builtins.typeOf optVal;
        encodedVal =
          if optType == "string"
          then "\"${optVal}\""
          else if optType == "bool"
          then
            if optVal
            then "True"
            else "False"
          else toString optVal;
      in "${optName}=${encodedVal}")
      value;
  in
    builtins.toFile name ''
      [/Script/Pal.PalGameWorldSettings]
      OptionSettings=(${concatStringsSep "," optionSettings})
    '';

  baseSettings = {
    ServerName = "Unnamed Server";
    AllowConnectPlatform = "Steam";
    CoopPlayerMaxNum = cfg.maxPlayers;
    bIsUseBackupSaveData = true;
    RCONEnabled = false;
    RESTAPIEnabled = false;
  };
in
{
  options.modules.games.palworld = {
    enable = mkOption {
      default = false;
      description = "Whether to enable Palworld Dedicated Server.";
      type = types.bool;
    };

    package = mkOption {
      type = types.package;
      default = pkgs.palworld-server;
    };

    public = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable Community Server mode";
    };

    autostart = mkOption {
      default = false;
      type = types.bool;
    };

    datadir = mkOption {
      type = types.path;
      default = "${baseCfg.datadir}/palworld";
    };

    ip = mkOption {
      type = types.nullOr types.str;
      default = "0.0.0.0";
    };

    port = mkOption {
      type = types.port;
      default = 8211;
    };

    threads = mkOption {
      type = types.int;
      default = 4;
    };

    maxPlayers = mkOption {
      type = types.int;
      default = 6;
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
    };
  };

  config = mkIf isEnabled {
    age.secrets."palworld-passwd.raw" = {
      file = ./encrypt/palworld-passwd.age;
      group = "${baseCfg.group}";
      owner = "${baseCfg.user}";
      mode = "770";
    };

    modules.router.nftables.capturePorts = [ cfg.port ];
    networking.firewall.allowedUDPPorts = [ cfg.port ];

    systemd.tmpfiles.rules = [
      "d ${cfg.datadir} 0755 ${baseCfg.user} ${baseCfg.group} - -"
    ];

    systemd.services."${name}" = let
      dirs = {
        Pal = "${cfg.package}/Pal";
        Engine = "${cfg.package}/Engine";
      };

      files = let
        settings = baseSettings // cfg.settings // {
          ServerPassword = "@SERVER_PASSWORD@";
        };
      in {
        "Pal/Binaries/Linux/steamclient.so" = "${pkgs.steamworks-sdk-redist}/lib/steamclient.so";
        "Pal/Saved/Config/LinuxServer/PalWorldSettings.ini" = generateSettings "PalWorldSettings.ini" settings;
        "Pal/Saved/Config/LinuxServer/Engine.ini" = ./Engine.ini;
      };

      script = let
        args = [
          "Pal"
          "-port=${toString cfg.port}"
          "-useperfthreads"
          "-NoAsyncLoadingThread"
          "-UseMultithreadForDS"
          "-players=${toString cfg.maxPlayers}"
          "-NumberOfWorkerThreadsServer=${toString cfg.threads}"
        ]
          ++ optionals (cfg.ip != null) [ "-publicip=${cfg.ip}" ]
          ++ optionals cfg.public [ "-publiclobby" ];
        bin = getExe (pkgs.mkSteamWrapper "${cfg.datadir}/Pal/Binaries/Linux/PalServer-Linux-Shipping");
      in "${bin} ${concatStringsSep " " args}";
    in {
      wantedBy = mkIf cfg.autostart [ "multi-user.target" ];
      after = [ "network.target" ];
      path = with pkgs; [ xdg-user-dirs util-linux ];

      inherit script;
      preStart = let
        passwordFile = config.age.secrets."palworld-passwd.raw".path;
      in ''
        export SERVER_PASSWORD=$(cat "${passwordFile}")
        ${scripts.mkDirs name dirs}
        ${scripts.mkFiles name files}
      '';

      serviceConfig = {
        Restart = "on-failure";
        User = "${baseCfg.user}";
        Group = "${baseCfg.group}";
        WorkingDirectory = "${cfg.datadir}";

        CPUWeight = 80;
        CPUQuota = "${toString ((cfg.threads + 1) * 100)}%";

        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectProc = "noaccess";
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        RestrictRealtime = true;
        LockPersonality = true;

        # Palworld needs namespaces and system calls
        RestrictNamespaces = false;
        SystemCallFilter = [];
      };
    };
  };
}
