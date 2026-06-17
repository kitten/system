{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.development;
in {
  options.modules.development.claude = {
    enable = mkOption {
      default = cfg.js.enable || cfg.react-native.enable;
      example = true;
      description = "Whether to enable Claude Code configuration.";
      type = types.bool;
    };
  };

  config = mkIf cfg.claude.enable {
    programs.claude-code = {
      enable = true;
      package = pkgs.claude-code;
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
