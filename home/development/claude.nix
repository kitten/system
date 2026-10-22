{ lib, config, pkgs, osConfig, ... }:

with lib;
let
  cfg = config.modules.development;
  auth = import ../../lib/shell-env-wrapper.nix { inherit lib pkgs; };
in {
  options.modules.development.claude = {
    environmentFile = auth.environmentFileOptions ./encrypt/claude.env.age;

    enable = mkOption {
      default = cfg.js.enable || cfg.react-native.enable;
      example = true;
      description = "Whether to enable Claude Code configuration.";
      type = types.bool;
    };

    package = mkOption {
      default = pkgs.claude-code;
      description = "Claude Code CLI package.";
      type = types.package;
    };
  };

  config = mkIf cfg.claude.enable {
    programs.claude-code = {
      enable = true;
      package = auth.wrap cfg.claude.package (auth.runtimeFiles "${config.home.username}-claude" cfg.claude.environmentFile osConfig.age.secrets) [ "claude" ];
      settings = {
        env = {
          DISABLE_UPDATES = "1";
          DISABLE_FEEDBACK_COMMAND = "1";
          DISABLE_ERROR_REPORTING = "1";
          CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING = "1";
        };
        autoUpdates = false;
        includeCoAuthoredBy = false;
        spinnerTipsEnabled = false;
        awaySummaryEnabled = false;
        disableRemoteControl = false;
        feedbackSurveyRate = 0.0;
        editorMode = "vim";
        theme = "dark-ansi";
        effortLevel = "high";
      };
    };
  };
}
