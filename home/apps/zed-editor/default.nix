{ lib, config, pkgs, helpers, ... } @ inputs:

with lib;
let
  themes = (import ./theme.nix inputs);
  cfg = config.modules.apps;

  userSettings = {
    ui_font_family = "SF Pro Text";
    ui_font_fallbacks = [ "codicon" ];
    ui_font_size = 14;
    buffer_font_family = "Dank Mono";
    buffer_font_size = 14;
    buffer_line_height.custom = 1.2;
    tab_size = 2;

    load_direnv = "shell_hook";

    theme = "System Dark";

    scrollbar.show = "never";
    tab_bar.show = false;
    git.inline_blame.enabled = false;
    indent_guides.enabled = false;
    seed_search_query_from_cursor = "selection";
    use_smartcase_search = true;
    use_autoclose = false;
    inline_code_actions = false;
    cursor_blink = false;

    vim_mode = true;

    calls = {
      mute_on_join = true;
      share_on_join = false;
    };

    toolbar = {
      breadcrumbs = false;
      quick_actions = false;
      selections_menu = false;
      agent_review = false;
      code_actions = false;
    };

    telemetry = {
      diagnostics = false;
      metrics = false;
    };

    language_models = {
      ollama.api_url = "http://irnbru.fable-pancake.ts.net:11434";
      lmstudio.api_url = "http://irnbru.fable-pancake.ts.net:1234/api/v0";
    };
  };
in {
  options.modules.apps.zed-editor = {
    enable = mkOption {
      default = false;
      description = "Whether to enable Zed Editor.";
      type = types.bool;
    };
  };

  config = mkIf (cfg.enable && cfg.zed-editor.enable) {
    programs.zed-editor = {
      enable = true;
      installRemoteServer = true;
      inherit themes userSettings;
    };
  };
}
