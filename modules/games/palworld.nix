{ lib, config, pkgs, ... } @ args:

with lib;
let
  isEnabled = config.modules.games.enable && config.modules.games.palworld.enable;
  baseCfg = config.modules.games;
  cfg = config.modules.games.palworld;

  name = "palworld-server";
  serverScripts = (import ./lib/serverScripts.nix) args;
  mkWrappedBox64 = (import ./lib/mkWrappedBox64.nix) args;
  mkSteamPackage = (import ./lib/mkSteamPackage.nix) args;
  inherit ((import ./lib/steamworks.nix) args) steamworks-sdk-redist;

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

  wrappedBox64 = mkWrappedBox64 {
    libs = [ pkgs.pkgsCross.gnu64.libgcc ];
  };

  palworld-server = mkSteamPackage {
    name = "palworld-server";
    version = "17082920";
    appId = "2394010";
    depotId = "2394012";
    manifestId = "2423583208459052375";
    hash = "sha256-gAFEDf/rKPQ5zTH8EJ93e4KKHUGi8uiYlPS7G2lWGWk=";
    meta = {
      description = "Palworld Dedicated Server";
      homepage = "https://steamdb.info/app/2394010/";
      changelog = "https://store.steampowered.com/news/app/1623730?updates=true";
      sourceProvenance = with sourceTypes; [ sourceTypes.binaryNativeCode ];
    };
  };

  baseSettings = {
    ServerName = "London Boroughs";
    AllowConnectPlatform = "Xbox";
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
      default = palworld-server;
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
      default = {
        PublicPort = 8211;
        PublicIP = cfg.ip;
        AllowConnectPlatform = "Xbox";
      };
    };
  };

  config = mkIf isEnabled {
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
        settings = baseSettings // cfg.settings;
      in {
        "Pal/Binaries/Linux/steamclient.so" = "${steamworks-sdk-redist}/lib/steamclient.so";
        "Pal/Saved/Config/LinuxServer/PalWorldSettings.ini" = generateSettings "PalWorldSettings.ini" settings;
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
        ] ++ optionals (cfg.ip != null) [ "-publicip=${cfg.ip}" ];
        executable = "${cfg.datadir}/Pal/Binaries/Linux/PalServer-Linux-Shipping";
        command = "${wrappedBox64}/bin/box64 ${executable}";
      in "${command} ${concatStringsSep " " args}";
    in {
      wantedBy = mkIf cfg.autostart [ "multi-user.target" ];
      after = [ "network.target" ];
      path = with pkgs; [ xdg-user-dirs util-linux ];

      inherit script;
      preStart = ''
        ${serverScripts.mkDirs name dirs}
        ${serverScripts.mkFiles name files}
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
