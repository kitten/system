{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.shell;
in {
  options.modules.shell = {
    enable = mkOption {
      default = true;
      description = "Shell";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableVteIntegration = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        ls = "ls --color=auto";
        ll = "ls -l";
        wx = "wezmux";
        http = "xh";
      };
      sessionVariables = {
        KEYTIMEOUT = "1";
        VIM_MODE_TRACK_KEYMAP = "no";
        MODE_INDICATOR = "";
        PURE_GIT_PULL = "0";
        PURE_PROMPT_SYMBOL = "➜";
        PURE_PROMPT_VICMD_SYMBOL = "➜";
        PURE_GIT_UP_ARROW = " ";
        PURE_GIT_DOWN_ARROW = " ";
        PURE_GIT_STASH_SYMBOL = " ";
      };
      plugins = [
        {
          name = "pure-prompt";
          file = "share/zsh/site-functions/async";
          src = pkgs.pure-prompt;
        }
        {
          name = "pure-prompt";
          file = "share/zsh/site-functions/prompt_pure_setup";
          src = pkgs.pure-prompt;
        }
      ];
      initExtra = /*sh*/''
        setopt NO_NOMATCH
        stty -ixon -ixoff
      '';
    };

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = mkDefault false;
      enableFishIntegration = mkDefault false;
    };
  };
}
