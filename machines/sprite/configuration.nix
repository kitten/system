{ pkgs, ... }:

{
  imports = [ ];

  modules = {
    fonts.enable = true;
    nvim.enable = true;
  };

  # Use built-in TouchID PAM
  security.pam.enableSudoTouchIdAuth = true;

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

  environment.systemPackages = with pkgs; [
    coreutils
    openssl
    imagemagick
    ffmpeg
    pngquant
    ripgrep
    xh
    curl
    sd
    fd
    cloudflared
    woff2
    temporal
    dive
    caddy
    flyctl
  ];
}
