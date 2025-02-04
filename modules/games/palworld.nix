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
    ServerPassword = "onlyflans";
    AllowConnectPlatform = "Xbox";
    CoopPlayerMaxNum = cfg.maxPlayers;
    bIsUseBackupSaveData = true;
    RCONEnabled = false;
    RESTAPIEnabled = false;
  };

  engineSettings = ''
    [Core.System]
    Paths=../../../Engine/Content
    Paths=%GAMEDIR%Content
    Paths=../../../Engine/Plugins/2D/Paper2D/Content
    Paths=../../../Engine/Plugins/Animation/ControlRigSpline/Content
    Paths=../../../Engine/Plugins/Animation/ControlRig/Content
    Paths=../../../Engine/Plugins/Animation/IKRig/Content
    Paths=../../../Engine/Plugins/Animation/MotionWarping/Content
    Paths=../../../Engine/Plugins/Bridge/Content
    Paths=../../../Engine/Plugins/Compositing/Composure/Content
    Paths=../../../Engine/Plugins/Compositing/OpenColorIO/Content
    Paths=../../../Engine/Plugins/Developer/AnimationSharing/Content
    Paths=../../../Engine/Plugins/Developer/Concert/ConcertSync/ConcertSyncClient/Content
    Paths=../../../Engine/Plugins/Editor/BlueprintHeaderView/Content
    Paths=../../../Engine/Plugins/Editor/GeometryMode/Content
    Paths=../../../Engine/Plugins/Editor/ModelingToolsEditorMode/Content
    Paths=../../../Engine/Plugins/Editor/ObjectMixer/LightMixer/Content
    Paths=../../../Engine/Plugins/Editor/ObjectMixer/ObjectMixer/Content
    Paths=../../../Engine/Plugins/Editor/SpeedTreeImporter/Content
    Paths=../../../Engine/Plugins/Enterprise/DatasmithContent/Content
    Paths=../../../Engine/Plugins/Enterprise/GLTFExporter/Content
    Paths=../../../Engine/Plugins/Experimental/ChaosCaching/Content
    Paths=../../../Engine/Plugins/Experimental/ChaosClothEditor/Content
    Paths=../../../Engine/Plugins/Experimental/ChaosNiagara/Content
    Paths=../../../Engine/Plugins/Experimental/ChaosSolverPlugin/Content
    Paths=../../../Engine/Plugins/Experimental/CommonUI/Content
    Paths=../../../Engine/Plugins/Experimental/Dataflow/Content
    Paths=../../../Engine/Plugins/Experimental/FullBodyIK/Content
    Paths=../../../Engine/Plugins/Experimental/GeometryCollectionPlugin/Content
    Paths=../../../Engine/Plugins/Experimental/GeometryFlow/Content
    Paths=../../../Engine/Plugins/Experimental/ImpostorBaker/Content
    Paths=../../../Engine/Plugins/Experimental/Landmass/Content
    Paths=../../../Engine/Plugins/Experimental/MeshLODToolset/Content
    Paths=../../../Engine/Plugins/Experimental/PythonScriptPlugin/Content
    Paths=../../../Engine/Plugins/Experimental/StaticMeshEditorModeling/Content
    Paths=../../../Engine/Plugins/Experimental/UVEditor/Content
    Paths=../../../Engine/Plugins/Experimental/Volumetrics/Content
    Paths=../../../Engine/Plugins/Experimental/Water/Content
    Paths=../../../Engine/Plugins/FX/Niagara/Content
    Paths=../../../Engine/Plugins/JsonBlueprintUtilities/Content
    Paths=../../../Engine/Plugins/Media/MediaCompositing/Content
    Paths=../../../Engine/Plugins/Media/MediaPlate/Content
    Paths=../../../Engine/Plugins/MovieScene/SequencerScripting/Content
    Paths=../../../Engine/Plugins/PivotTool/Content
    Paths=../../../Engine/Plugins/PlacementTools/Content
    Paths=../../../Engine/Plugins/Runtime/AudioSynesthesia/Content
    Paths=../../../Engine/Plugins/Runtime/AudioWidgets/Content
    Paths=../../../Engine/Plugins/Runtime/GeometryProcessing/Content
    Paths=../../../Engine/Plugins/Runtime/Metasound/Content
    Paths=../../../Engine/Plugins/Runtime/ResonanceAudio/Content
    Paths=../../../Engine/Plugins/Runtime/SunPosition/Content
    Paths=../../../Engine/Plugins/Runtime/Synthesis/Content
    Paths=../../../Engine/Plugins/Runtime/WaveTable/Content
    Paths=../../../Engine/Plugins/Runtime/WebBrowserWidget/Content
    Paths=../../../Engine/Plugins/SkyCreatorPlugin/Content
    Paths=../../../Engine/Plugins/VirtualProduction/CameraCalibrationCore/Content
    Paths=../../../Engine/Plugins/VirtualProduction/LiveLinkCamera/Content
    Paths=../../../Engine/Plugins/VirtualProduction/Takes/Content
    Paths=../../../Engine/Plugins/Web/HttpBlueprint/Content
    Paths=../../../Pal/Plugins/DLSS/Content
    Paths=../../../Pal/Plugins/EffectsChecker/Content
    Paths=../../../Pal/Plugins/HoudiniEngine/Content
    Paths=../../../Pal/Plugins/PPSkyCreatorPlugin/Content
    Paths=../../../Pal/Plugins/PocketpairUser/Content
    Paths=../../../Pal/Plugins/SpreadSheetToCsv/Content
    Paths=../../../Pal/Plugins/Wwise/Content

    [/script/onlinesubsystemutils.ipnetdriver]
    LanServerMaxTickRate=60
    NetServerMaxTickRate=60

    [/script/engine.player]
    ConfiguredInternetSpeed=104857600
    ConfiguredLanSpeed=104857600

    [/script/socketsubsystemepic.epicnetdriver]
    MaxClientRate=104857600
    MaxInternetClientRate=104857600

    [/script/engine.engine]
    bSmoothFrameRate=true
    SmoothedFrameRateRange=(LowerBound=(Type=Inclusive,Value=30.000000),UpperBound=(Type=Exclusive,Value=60.000000))
    bUseFixedFrameRate=false
    FixedFrameRate=60
    MinDesiredFrameRate=30
    NetClientTicksPerSecond=60
  '';
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
        "Pal/Saved/Config/LinuxServer/Engine.ini" = builtins.toFile "Engine.ini" engineSettings;
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
