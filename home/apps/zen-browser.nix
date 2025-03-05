{ lib, config, pkgs, helpers, ... }:

with lib;
let
  cfg = config.modules.apps;
in {
  options.modules.apps.zen-browser = {
    enable = mkOption {
      default = false;
      description = "Whether to enable Zen.";
      type = types.bool;
    };
  };

  config.modules.apps.zen-browser = {
    enable = if helpers.isLinux then (mkDefault false) else (mkForce false);
  };
} // helpers.linuxAttrs {
  config = mkIf (cfg.enable && cfg.zen-browser.enable) {
    home.packages = [ pkgs.zen-browser ];

    systemd.user.sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
      MOZ_WEBRENDER = 1;
      NIXOS_OZONE_WL = mkDefault 1;
    };

    xdg = {
      mimeApps = {
        enable = mkDefault true;
        defaultApplications = let
          browser = [ "zen-beta.desktop" ];
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
