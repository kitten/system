{ pkgs, ... }:

{
  imports = [
    ../config/yabai.nix
    ../config/skhd.nix
  ];

  system = {
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
      dock = {
        autohide = true;
        tilesize = 46;
      };
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 10;
        KeyRepeat = 2;
      };
    };
  };

  environment.systemPackages = [
    pkgs.coreutils
  ];
}
