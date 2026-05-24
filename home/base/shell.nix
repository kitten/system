{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.shell;

  # Vendored fork of pure-prompt 1.27.0 (MIT, https://github.com/sindresorhus/pure)
  # — files live at ./zsh/. Forked so we own the color palette (only ANSI 0-15).
  prompt-src = ./zsh;
in {
  options.modules.shell = {
    enable = mkOption {
      default = true;
      description = "Shell";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    home.file.".hushlogin".text = "";

    programs.zsh = rec {
      enable = true;
      enableCompletion = true;
      enableVteIntegration = true;
      autosuggestion.enable = true;
      # Disabled: we source it via zsh-defer below so it loads after first prompt
      syntaxHighlighting.enable = false;
      dotDir = "${config.xdg.configHome}/zsh";
      completionInit = ''
        autoload -Uz compinit
        # Anonymous function scopes extended_glob/local_options so they don't
        # leak globally — local_options would otherwise undo prompt_subst when
        # prompt_pure_setup() returns, breaking prompt expansion.
        () {
          setopt localoptions extended_glob
          if [[ -n $ZDOTDIR/.zcompdump(#qN.mh+24) ]]; then
            compinit
          else
            compinit -C
          fi
        }
      '';
      shellAliases = {
        ls = "ls --color=auto";
        ll = "ls -l";
        http = "xh";
      };
      history = {
        append = true;
        expireDuplicatesFirst = true;
        path = "${config.xdg.stateHome}/zsh/zsh_history";
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
        ZDOTDIR = "${config.xdg.configHome}/zsh";
      };
      plugins = [
        {
          name = "pure-prompt";
          file = "async.zsh";
          src = prompt-src;
        }
        {
          name = "pure-prompt";
          file = "prompt_pure_setup.zsh";
          src = prompt-src;
        }
      ];
      initContent = /*sh*/''
        setopt NO_NOMATCH
        stty -ixon -ixoff
        # Pre-evaluated hooks (avoid forking on every shell start)
        source ${pkgs.runCommand "direnv-hook.zsh" {} ''
          ${pkgs.direnv}/bin/direnv hook zsh > $out
        ''}
        source ${pkgs.runCommand "zoxide-init.zsh" {} ''
          ${pkgs.zoxide}/bin/zoxide init zsh > $out
        ''}
        # Defer syntax-highlighting until after the first prompt is drawn
        source ${pkgs.zsh-defer}/share/zsh-defer/zsh-defer.plugin.zsh
        zsh-defer source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)
      '';
    };

    programs.direnv = {
      enable = true;
      enableZshIntegration = false;
      nix-direnv.enable = true;
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = false;
      enableNushellIntegration = mkDefault false;
      enableFishIntegration = mkDefault false;
    };
  };
}
