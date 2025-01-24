{ lib, config, inputs, pkgs, user, ... }:

with lib;
let
  cfg = config.modules.apps;

  gamescope = pkgs.gamescope.overrideAttrs (old: {
    version = "3.16.1-f873ec7";
    patches = [];
    src = pkgs.fetchFromGitHub {
      owner = "ValveSoftware";
      repo = "gamescope";
      rev = "f873ec7868fe84d2850e91148bcbd6d6b19a7443";
      fetchSubmodules = true;
      hash = "sha256-ItP9VE4IMgnIPDeDQag+gVZMuoRO0uI6gF2tC4WVObE=";
    };
    buildInputs = old.buildInputs ++ [ pkgs.luajit ];
    # See: https://github.com/ValveSoftware/gamescope/pull/1494
    NIX_CFLAGS_COMPILE = [ "-fno-fast-math" "-fno-omit-frame-pointer" ];
    patchPhase = ''
      substituteInPlace ./src/reshade_effect_manager.cpp \
        --replace-fail "\"/usr\"" "\"$out\""
      substituteInPlace ./src/Utils/Process.cpp \
        --replace-fail "\"gamescopereaper\"" "\"$out/bin/gamescopereaper\""
      patchShebangs ./default_scripts_install.sh
      patchShebangs ./subprojects/libdisplay-info/tool/gen-search-table.py
    '';
  });
in {
  options.modules.apps.games = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable games.";
      type = types.bool;
    };

    hdr = mkOption {
      default = cfg.games.enable;
      example = true;
      description = "Whether to enable HDR.";
      type = types.bool;
    };
  };

  config = mkIf (cfg.enable && cfg.games.enable) {
    boot.kernel.sysctl = {
      "kernel.unprivileged_userns_clone" = true;
    };

    environment.sessionVariables = {
      PROTONPATH = "${pkgs.proton-ge-bin.steamcompattool}/";
      PROTON_ENABLE_AMD_AGS = "1";
      ENABLE_HDR_WSI = "1";
      DXVK_HDR = "1";
    };

    hardware.steam-hardware.enable = true;
    users.users."${user}".extraGroups = [ "gamemode" ];
    services.system76-scheduler.enable = true;

    environment.systemPackages = [
      (pkgs.lutris.override {
        extraPkgs = (pkgs: with pkgs; [ gamemode ]);
      })
    ];

    programs = {
      gamemode.enable = true;
      gamescope = {
        enable = true;
        package = gamescope;
        env = {
          PROTON_ENABLE_AMD_AGS = "1";
          ENABLE_HDR_WSI = "1";
          DXVK_HDR = "1";
        };
        args = [
          "--backend" "wayland"
          "--adaptive-sync"
          "--expose-wayland"
          "--hdr-enabled"
          "--immediate-flips"
          "--force-grab-cursor"
          "--rt"
          "-f"
          "-S" "fit"
          "-W" "2560"
          "-H" "1440"
          "-r" "360"
        ];
      };
      steam = {
        enable = true;
        package = pkgs.steam.override {
          extraPkgs = pkgs: [ pkgs.gamemode ];
        };
        remotePlay.openFirewall = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
      };
    };

    networking.hosts."0.0.0.0" = [ "ipv6check-http.steamserver.net" ];
  };
}
