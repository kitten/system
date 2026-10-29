{ lib, config, pkgs, osConfig, ... }:

with lib;
let
  cfg = config.modules.development.t3code;
  json = pkgs.formats.json { };
  settings = json.generate "t3code-settings.json" cfg.settings;
  auth = import ../../lib/shell-env-wrapper.nix { inherit lib pkgs; };
  envFiles = auth.runtimeFiles "${config.home.username}-t3code" cfg.environmentFile osConfig.age.secrets;
  wrapperArgs = [
    "--set-default" "T3CODE_TELEMETRY_ENABLED" (boolToString cfg.telemetry)
    "--set" "T3CODE_DISABLE_AUTO_UPDATE" "true"
  ]
    ++ concatLists (mapAttrsToList (name: value: [ "--set-default" name value ]) cfg.environment)
    ++ auth.wrapperArgs envFiles;

  configureSettings = pkgs.writeShellScript "t3code-settings" ''
    set -euo pipefail
    umask 077
    directory=${escapeShellArg "${config.home.homeDirectory}/.t3/userdata"}
    mkdir -p "$directory"
    temporary=$(mktemp "$directory/settings.json.XXXXXX")
    trap 'rm -f "$temporary"' EXIT
    touch "$directory/settings.json"
    ${pkgs.jq}/bin/jq -s 'reduce .[] as $settings ({}; . * $settings)' \
      "$directory/settings.json" ${settings} > "$temporary"
    mv "$temporary" "$directory/settings.json"
  '';

  cliPackage = pkgs.runCommand "t3code-cli" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
    mkdir -p $out/bin
    makeWrapper ${cfg.package}/bin/t3 $out/bin/t3 ${escapeShellArgs wrapperArgs}
  '';

  # nixpkgs' "T3 Code (Alpha).app" runs the *unwrapped* t3code-desktop; point
  # the bundle at the wrapped binary instead.
  desktopPackage = pkgs.symlinkJoin {
    name = "t3code-desktop-${cfg.package.version or "unknown"}";
    paths = [ cfg.package ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      for program in t3 t3code-desktop; do
        rm "$out/bin/$program"
        makeWrapper ${cfg.package}/bin/$program "$out/bin/$program" ${escapeShellArgs wrapperArgs}
      done
    '' + optionalString pkgs.stdenv.hostPlatform.isDarwin ''
      for exe in "$out"/Applications/*.app/Contents/MacOS/*; do
        rm "$exe"
        ln -s "$out/bin/t3code-desktop" "$exe"
      done
    '';
    meta = (cfg.package.meta or { }) // { mainProgram = "t3code-desktop"; };
  };
in {
  options.modules.development.t3code = {
    environment = mkOption {
      type = types.attrsOf types.str;
      default = {
        T3CODE_CLOUDFLARED_PATH = "${pkgs.cloudflared}/bin/cloudflared";
        T3CODE_CLERK_PUBLISHABLE_KEY = "pk_live_Y2xlcmsudDMuY29kZXMk";
        T3CODE_CLERK_CLI_OAUTH_CLIENT_ID = "hzxSgY2cH10sDU2r";
        T3CODE_RELAY_URL = "https://relay.t3.codes";
      };
      description = "Default runtime environment shared by the T3 wrappers and server. Public configuration only; use environmentFile for credentials.";
    };

    settings = mkOption {
      default = { };
      type = json.type;
      description = "T3 server settings merged on activation; declared values override UI settings.";
    };

    environmentFile = auth.environmentFileOptions [
      ./encrypt/cursor.env.age
      ./encrypt/grok.env.age
    ];

    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to install the T3 Code CLI and optional desktop app.";
      type = types.bool;
    };

    package = mkOption {
      default = pkgs.t3code.override {
        enableCodex = false;
        enableGitHub = false;
        enableGit = false;
      };
      defaultText = literalExpression "pkgs.t3code.override { enableCodex = false; enableGitHub = false; enableGit = false; }";
      description = "T3 Code package (bin/t3, bin/t3code-desktop, and the macOS app bundle).";
      type = types.package;
    };

    telemetry = mkOption {
      default = false;
      example = true;
      description = "Whether T3 Code sends anonymous usage data.";
      type = types.bool;
    };

    desktop = {
      enable = mkOption {
        default = true;
        example = false;
        description = ''
          Whether to install the desktop app alongside the `t3` CLI. The app runs
          its own local server as this user; remote servers are paired in the app.
        '';
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    modules.development.t3code.settings = {
      enableProviderUpdateChecks = mkDefault false;
      worktreesDirectory = mkDefault "${config.modules.git.directory}/.worktrees";
    };
    home.packages = [ (if cfg.desktop.enable then desktopPackage else cliPackage) ];
    home.activation.t3codeSettings = mkIf (cfg.settings != { }) (hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${configureSettings}
    '');
  };
}
