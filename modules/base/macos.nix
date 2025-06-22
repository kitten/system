{ lib, pkgs, user, helpers, ... } @ inputs:

with lib;
helpers.darwinAttrs {
  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    primaryUser = "${user}";

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
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 10;
        KeyRepeat = 2;
        AppleInterfaceStyle = "Dark";
        AppleShowScrollBars = "WhenScrolling";
        "com.apple.swipescrolldirection" = false;
      };
      spaces.spans-displays = false;
    };
  };
}
