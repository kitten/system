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

  # Route Finder launches through the environment wrapper too.
  desktopPackage = pkgs.symlinkJoin {
    name = "t3code-desktop-${cfg.desktop.package.version or "unknown"}";
    paths = [ cfg.desktop.package ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      for program in t3 t3code-desktop; do
        [ -e "$out/bin/$program" ] || continue
        rm "$out/bin/$program"
        makeWrapper ${cfg.desktop.package}/bin/$program "$out/bin/$program" ${escapeShellArgs wrapperArgs}
      done
    '' + optionalString pkgs.stdenv.hostPlatform.isDarwin ''
      for exe in "$out"/Applications/*.app/Contents/MacOS/*; do
        rm "$exe"
        ln -s "$out/bin/t3code-desktop" "$exe"
      done
    '';
    meta = (cfg.desktop.package.meta or { }) // { mainProgram = "t3code-desktop"; };
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
      description = "Whether to install T3 Code.";
      type = types.bool;
    };

    package = mkOption {
      default = pkgs.t3code.override {
        enableCodex = false;
        enableGitHub = false;
        enableGit = false;
      };
      defaultText = literalExpression "pkgs.t3code.override { enableCodex = false; enableGitHub = false; enableGit = false; }";
      description = "T3 Code CLI/server package providing bin/t3, independent of the desktop package.";
      type = types.package;
    };

    telemetry = mkOption {
      default = false;
      example = true;
      description = "Whether T3 Code sends anonymous usage data.";
      type = types.bool;
    };

    cli.enable = mkOption {
      default = !cfg.desktop.enable;
      defaultText = literalExpression "!config.modules.development.t3code.desktop.enable";
      description = "Whether to install the standalone t3 CLI. Defaults to enabled only without the desktop app.";
      type = types.bool;
    };

    desktop = {
      package = mkOption {
        default = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.t3code-desktop-bin else cfg.package;
        defaultText = literalExpression "if pkgs.stdenv.hostPlatform.isDarwin then pkgs.t3code-desktop-bin else config.modules.development.t3code.package";
        description = "Desktop package providing bin/t3code-desktop and, on macOS, an app bundle.";
        type = types.package;
      };

      enable = mkOption {
        default = true;
        example = false;
        description = ''
          Whether to install the desktop app. The app runs
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
      defaultThreadEnvMode = mkDefault "local";
      branchNamingMode = mkDefault "custom";
      branchNameInstructions = mkDefault "Use `@kitten/` followed by semantic keyword (`fix/`, `refactor/`, `chore/`, etc), followed by short description or issue ID.";
      removeAgentCreditsOnMerge = mkDefault true;
      pullRequestMergeMethod = mkDefault "squash";
    };
    home.packages = optional cfg.desktop.enable desktopPackage ++ optional cfg.cli.enable cliPackage;
    home.activation.t3codeSettings = mkIf (cfg.settings != { }) (hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${configureSettings}
    '');
  };
}
