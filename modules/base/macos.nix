{ lib, pkgs, user, helpers, ... } @ inputs:

with lib;
helpers.darwinAttrs {
  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    primaryUser = "${user}";

    activationScripts.postActivation.text = ''
      # disable spotlight
      launchctl unload -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist >/dev/null 2>&1 || true
      # disable fseventsd on /nix volume
      mkdir -p /nix/.fseventsd
      test -e /nix/.fseventsd/no_log || touch /nix/.fseventsd/no_log
    '';

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
      nonUS.remapTilde = true;
    };

    defaults = {
      finder.CreateDesktop = false;
      screencapture.location = "~/Screenshots";
      loginwindow = {
        GuestEnabled = false;
        DisableConsoleAccess = true;
      };
      menuExtraClock = {
        IsAnalog = true;
        ShowAMPM = true;
        ShowDayOfWeek = true;
        ShowDate = 0;
      };
      dock = {
        autohide = true;
        tilesize = 46;
        mru-spaces = false;
      };
      LaunchServices.LSQuarantine = false;
      NSGlobalDomain = {
        AppleMeasurementUnits = "Centimeters";
        AppleMetricUnits = 1;
        AppleTemperatureUnit = "Celsius";
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 10;
        KeyRepeat = 2;
        AppleInterfaceStyle = "Dark";
        AppleShowScrollBars = "WhenScrolling";
        "com.apple.swipescrolldirection" = false;
      };
      spaces.spans-displays = false;

      CustomSystemPreferences = {
        "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
        "com.apple.ImageCapture".disableHotPlug = true;
        "com.apple.gamed".Disabled = true;
        "com.apple.dt.XCode".IDEIndexDisable = 1;
      };
    };
  };
}
