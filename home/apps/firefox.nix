{ config, ... } @ inputs:

{
  programs.firefox = {
    enable = true;
    enableGnomeExtensions = false;
  };

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    MOZ_WEBRENDER = 1;
  };

  systemd.user.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    MOZ_WEBRENDER = 1;
    BROWSER = "firefox";
  };

  xdg = {
    mimeApps = {
      enable = true;
      defaultApplications = let
        browser = [ "firefox.desktop" ];
      in {
        "application/json" = browser;
        "application/pdf" = browser;
        "application/xml" = browser;
        "application/xhtml+xml" = browser;
        "application/xhtml_xml" = browser;
        "application/x-extension-htm" = browser;
        "application/x-extension-html" = browser;
        "x-scheme-handler/about" = browser;
        "x-scheme-handler/ftp" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/unknown" = browser;
        "text/html" = browser;
        "text/xml" = browser;
      };
    };
  };
}
