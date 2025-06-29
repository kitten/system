{ lib, system, helpers, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.development;

  android-arch = if helpers.system == "aarch64-darwin" then "arm64-v8a" else "x86-64";

  create-avd = pkgs.writeShellScriptBin "create-avd" ''
    avdmanager create avd \
      --name android-35 \
      --package 'system-images;android-35;google_apis_playstore;${android-arch}' \
      --tag google_apis_playstore \
      --device pixel_8 \
      --force
  '';
in {
  options.modules.development.react-native = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable React Native configuration.";
      type = types.bool;
    };

    android-sdk = mkOption {
      default = cfg.react-native.enable;
      type = types.bool;
    };

    android-studio = mkOption {
      default = cfg.react-native.enable && cfg.react-native.android-sdk;
      type = types.bool;
    };

    cocoapods = mkOption {
      default = cfg.react-native.enable;
      type = types.bool;
    };

    xcode = mkOption {
      default = cfg.react-native.enable;
      type = types.bool;
    };

    maestro = mkOption {
      default = cfg.react-native.enable;
      type = types.bool;
    };

    fastlane = mkOption {
      default = cfg.react-native.enable;
      type = types.bool;
    };
  };

  config = mkIf cfg.react-native.enable (mkMerge [
    {
      modules.development.react-native = {
        cocoapods = if helpers.isDarwin then (mkDefault true) else (mkForce false);
      };

      home.packages = with pkgs; [ ruby ] ++ optionals cfg.react-native.maestro [
        maestro
      ];
    }

    (helpers.mkIfDarwin {
      home.packages = with pkgs; []
        ++ optionals cfg.react-native.cocoapods [ cocoapods ]
        ++ optionals cfg.react-native.fastlane [ fastlane ];
      home.sessionVariables = {
        CP_HOME_DIR = mkIf cfg.react-native.cocoapods "${config.xdg.dataHome}/cocoapods";
      };
    })

    (mkIf cfg.react-native.android-sdk {
      home.packages = [
        pkgs.gradle_8
        create-avd
      ] ++ optionals (helpers.isLinux && cfg.react-native.android-studio) [
        pkgs.android-studio
      ];

      home.sessionVariables = rec {
        JAVA_HOME = pkgs.jdk.home;
        ANDROID_USER_HOME = "${config.xdg.stateHome}/android";
        ANDROID_AVD_HOME = "${ANDROID_USER_HOME}/avd";
        GRADLE_USER_HOME = "${config.xdg.dataHome}/gradle";
      };

      android-sdk = {
        enable = true;
        packages = sdk: with sdk; [
          build-tools-35-0-0
          cmdline-tools-latest
          emulator
          platform-tools
          platforms-android-35
          sources-android-35
          ndk-27-1-12297006
          cmake-3-22-1
          sdk."system-images-android-34-google-apis-${android-arch}"
          sdk."system-images-android-34-google-apis-playstore-${android-arch}"
        ];
      };
    })
  ]);
}
