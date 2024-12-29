{ lib, config, inputs, pkgs, user, ... }:

with lib;
let
  cfg = config.modules.apps;

  gamescope = pkgs.gamescope.overrideAttrs (old: {
    version = "3.15.14-d317492";
    patches = [];
    src = pkgs.fetchFromGitHub {
      owner = "ValveSoftware";
      repo = "gamescope";
      rev = "d3174928d47f7e353e7daca63cf882d65660cc7c";
      fetchSubmodules = true;
      hash = "sha256-94qvOyDARFQXHw8bhWOHXGsxEBqd/1LYdCatxSifaWA=";
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

  vk-hdr-layer = with pkgs; stdenv.mkDerivation rec {
    pname = "vk-hdr-layer";
    version = "2799ab320b6d4cd43a493c2f3a6c4670d647171c";
    src = fetchFromGitHub {
      owner = "Zamundaaa";
      repo = "VK_hdr_layer";
      rev = "2799ab320b6d4cd43a493c2f3a6c4670d647171c";
      hash = "sha256-j9IXzsC6EIHA3nuD2/iZttcw28CcES+ZzA7e2DgQ5Ks=";
    };
    nativeBuildInputs = [
      meson
      ninja
      pkg-config
    ];
    buildInputs = [
      vulkan-headers
      vulkan-loader
      wayland
      wayland-scanner
      xorg.libX11
    ];
    postPatch = let
      vkroots = fetchFromGitHub {
        owner = "misyltoad";
        repo = "vkroots";
        rev = "5106d8a0df95de66cc58dc1ea37e69c99afc9540";
        hash = "sha256-SgHFIWjifZ5L10/1RL7lXoX6evS5LsFvFKWMhHEHN0M=";
      };
    in ''
      rm -rf subprojects/vkroots
      cp -r ${vkroots} subprojects/vkroots
      chmod -R +w subprojects/vkroots
    '';
    meta = {
      maintainers = with lib.maintainers; [ xddxdd ];
      description = "Vulkan layer utilizing a small color management / HDR protocol for experimentation";
      homepage = "https://github.com/Zamundaaa/VK_hdr_layer";
      license = lib.licenses.mit;
    };
  };
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

    hardware = {
      steam-hardware.enable = true;
      graphics.extraPackages = mkIf cfg.games.hdr [ vk-hdr-layer ];
    };

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
