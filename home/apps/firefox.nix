{ lib, config, pkgs, helpers, ... }:

with lib;
let
  cfg = config.modules.apps;
in {
  options.modules.apps.firefox = {
    enable = mkOption {
      default = false;
      description = "Whether to enable Firefox.";
      type = types.bool;
    };
  };

  config.modules.apps.firefox = {
    enable = if helpers.isLinux then (mkDefault false) else (mkForce false);
  };
} // helpers.linuxAttrs {
  config = mkIf (cfg.enable && cfg.firefox.enable) {
    programs.firefox = {
      enable = true;
      package = with pkgs; (wrapFirefox (firefox-unwrapped.override { pipewireSupport = true; }) {});
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
          "media.hardware-video-decoding.force-enabled" = true;
          "media.hardwaremediakeys.enabled" = true;
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
          "font.default.x-western" = "sans-serif";
          "font.name.sans-serif.x-western" = "Inter";
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "gfx.webrender.all" = true;
        };
      };
    };

    systemd.user.sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
      MOZ_WEBRENDER = 1;
      NIXOS_OZONE_WL = mkDefault 1;
      BROWSER = "firefox";
    };

    xdg = {
      mimeApps = {
        enable = mkDefault true;
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
  };
}
