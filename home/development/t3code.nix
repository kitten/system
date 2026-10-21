{ lib, config, pkgs, osConfig, ... }:

with lib;
let
  cfg = config.modules.development.t3code;
  auth = import ../../lib/shell-env-wrapper.nix { inherit lib pkgs; };
  envFiles = auth.runtimeFiles "${config.home.username}-t3code" cfg.environmentFile osConfig.age.secrets;
  wrapperArgs = [ "--set-default" "T3CODE_TELEMETRY_ENABLED" (boolToString cfg.telemetry) ]
    ++ auth.wrapperArgs envFiles;

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
    home.packages = [ (if cfg.desktop.enable then desktopPackage else cliPackage) ];
  };
}
