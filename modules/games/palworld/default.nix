{ lib, config, pkgs, ... } @ args:

with lib;
let
  isEnabled = config.modules.games.enable && config.modules.games.palworld.enable;
  baseCfg = config.modules.games;
  cfg = config.modules.games.palworld;
  port = toString cfg.port;

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
      default = 5;
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

    systemd.sockets."${name}" = {
      wantedBy = [ "sockets.target" ];
      partOf = [ "${name}.service" ];
      listenDatagrams = [ "0.0.0.0:${port}" ];
      socketConfig = {
        SocketUser = "${baseCfg.user}";
        SocketGroup = "${baseCfg.group}";
      };
    };

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
          "-port=${port}"
          "-publicport=${port}"
          "-useperfthreads"
          "-NoAsyncLoadingThread"
          "-UseMultithreadForDS"
          "-players=${toString cfg.maxPlayers}"
          "-NumberOfWorkerThreadsServer=${toString cfg.threads}"
        ]
          ++ optionals (cfg.ip != null) [ "-publicip=${cfg.ip}" ]
          ++ optionals cfg.public [ "-publiclobby" ];
        bin = getExe (pkgs.mkSteamWrapper "${cfg.datadir}/Pal/Binaries/Linux/PalServer-Linux-Shipping");
        forceBind = "${getExe pkgs.force-bind} -m '0.0.0.0:${port}=sd=0'";
      in "${forceBind} ${bin} ${concatStringsSep " " args}";
    in {
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
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

        CPUWeight = 90;
        CPUQuota = "${toString ((cfg.threads + 1) * 100)}%";

        /*
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectProc = "noaccess";
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        RestrictRealtime = true;
        */

        # force-bind needs to stay unlocked and needs to be able to ptrace
        LockPersonality = false;
        CapabilityBoundingSet = [ "CAP_SYS_PTRACE" ];

        # Palworld needs namespaces and system calls
        RestrictNamespaces = false;
        SystemCallFilter = [];
      };
    };
  };
}
