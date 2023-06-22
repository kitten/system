{ config, ... } @ inputs:

{
  programs.firefox = {
    enable = true;
    enableGnomeExtensions = false;
    profiles.default = {
      settings = {
        "browser.aboutConfig.showWarning" = false;
        "browser.contentblocking.category" = "strict";
        "browser.newtabpage.enabled" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "privacy.annotate_channels.strict_list.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "browser.startup.homepage" = "about:blank";
        "trailhead.firstrun.didSeeAboutWelcome" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
        "font.default.x-western" = "sans-serif";
        "font.name.sans-serif.x-western" = "Inter";
        "dom.ipc.processCount" = 4;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };

      userChrome = ''
        .titlebar-min, .titlebar-max, .titlebar-restore, .titlebar-close {
          display: none !important;
        }
      '';
    };
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
