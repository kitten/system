{ lib, config, pkgs, osConfig, ... }:

with lib;
let
  cfg = config.modules.development.cursor;
  auth = import ../../lib/shell-env-wrapper.nix { inherit lib pkgs; };
  json = pkgs.formats.json { };
  settings = recursiveUpdate {
    version = 1;
    attribution = {
      attributeCommitsToAgent = false;
      attributePRsToAgent = false;
    };
  } cfg.settings;
  envFiles = auth.runtimeFiles "${config.home.username}-cursor" cfg.environmentFile osConfig.age.secrets;
  wrapperArgs = [ "--set-default" "CURSOR_CONFIG_DIR" cfg.configDir ] ++ auth.wrapperArgs envFiles;
  package = pkgs.symlinkJoin {
    name = "${cfg.package.name}-configured";
    paths = [ cfg.package ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/cursor-agent" ${escapeShellArgs wrapperArgs}
    '';
    meta = cfg.package.meta or { };
  };
in {
  options.modules.development.cursor = {
    enable = mkEnableOption "the cursor CLI";
    package = mkPackageOption pkgs "cursor-cli" { };
    environmentFile = auth.environmentFileOptions ./encrypt/cursor.env.age;
    configDir = mkOption {
      type = types.strMatching "/[^\n]+";
      default = "${config.xdg.configHome}/cursor";
      defaultText = literalExpression "\"\${config.xdg.configHome}/cursor\"";
      description = "Absolute directory for the writable Cursor CLI configuration.";
    };
    settings = mkOption {
      type = json.type;
      default = { };
      description = "Cursor CLI settings recursively merged with defaults on activation. Public configuration only; use environmentFile for credentials.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ package ];
    home.activation.cursorCliConfig = hm.dag.entryAfter [ "linkGeneration" ] (hm.generators.mkImpureConfigMerger {
      inherit pkgs;
      format = "json";
      empty = "{}";
      jqOperation = "$dynamic * $static";
      mode = "600";
      path = "${cfg.configDir}/cli-config.json";
      staticSettings = json.generate "cursor-cli-config.json" settings;
    });
  };
}
