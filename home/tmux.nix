{ lib, pkgs, ... } @ inputs:

let
  inherit (pkgs) stdenv;
  inherit (import ../lib/colors.nix inputs) colors;

  defaultActiveColor = colors.yellow.gui;
  defaultInactiveColor = colors.muted.gui;
  defaultFeatureColor = colors.blue.gui;
  defaultBorderColor = colors.green.gui;
  defaultSplitColor = colors.split.gui;
in {
  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 5000;
    keyMode = "vi";
    shortcut = "a";
    terminal = "xterm-256color";
    sensibleOnTop = false;

    secureSocket = stdenv.hostPlatform.isLinux;

    plugins = [ ];

    extraConfig = ''
      set -g mouse on
      set -g set-clipboard on

      set-option -g focus-events on

      set -g status-left-length 32
      set -g status-right-length 150
      set -g status-interval 5

      set-option -ga terminal-overrides ",xterm-256color*:Tc:smso"

      set-option -g status-style fg="${defaultActiveColor}",bg=default

      set-window-option -g window-status-style fg="${defaultInactiveColor}",bg=default
      set-window-option -g aggressive-resize on
      set-window-option -g window-status-current-style fg="${defaultActiveColor}",bg=default
      set-window-option -g window-status-current-format "#[bold]#I #W"
      set-option -g pane-border-style fg="${defaultInactiveColor}"
      set-option -g pane-active-border-style fg="${defaultBorderColor}"
      set-option -g message-style fg="${defaultActiveColor}",bg=default
      set-option -g display-panes-active-colour "${defaultActiveColor}"
      set-option -g display-panes-colour "${defaultInactiveColor}"
      set-window-option -g clock-mode-colour "${defaultActiveColor}"

      set -g window-status-format "#I #W"

      set -g status-left "#[fg=${defaultFeatureColor},bold]#S "
      set -g status-right "#[fg=${defaultInactiveColor}] %R %d %b"

      set -g pane-border-style fg="${defaultSplitColor}",bg="${defaultSplitColor}"
      set -g pane-active-border-style fg="${defaultSplitColor}",bg="${defaultSplitColor}"

      unbind C-p
      bind C-p paste-buffer

      bind -n C-h select-pane -L
      bind -n C-j select-pane -D
      bind -n C-k select-pane -U
      bind -n C-l select-pane -R

      bind -r h resize-pane -L 2
      bind -r j resize-pane -D 2
      bind -r k resize-pane -U 2
      bind -r l resize-pane -R 2

      bind b kill-pane
    '';
  };

  programs.zsh.shellAliases = {
    ta = "tmux attach -t";
    ts = "tmux new-session -s";
    tl = "tmux list-sessions";
    tksv = "tmux kill-server";
    tkss = "tmux kill-session -t";
  };
}
