{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;

    enableCompletion = false;

    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -l";
      wx = "wezmux";
      http = "xh";
    };

    initExtra = ''
      function update_title_preexec {
        emulate -L zsh
        setopt extended_glob
        local title=''${1[(wr)^(*=*|sudo|ssh|mosh|rake|-*)]:gs/%/%%}
        printf "\e]0;%s\e\\" "$title"
      }
      function update_title_precmd {
        emulate -L zsh
        setopt extended_glob
        local title=''${PWD##*/}
        printf "\e]0;%s\e\\" "$title"
      }

      add-zsh-hook preexec update_title_preexec
      add-zsh-hook precmd update_title_precmd
    '';

    plugins = [
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "91d2eeaf23c47341e8dc7ad66dbf85e38c2674de";
          sha256 = "1160bbhpd2p6qlw1b5k86z243iv0yhv6x7pf414sr8q4cm59x2h0";
        };
      }
    ];
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      add_newline = false;
      aws.disabled = true;
      cmd_duration.disabled = true;
      battery.disabled = true;
      nodejs.disabled = true;
      deno.disabled = true;
      character.success_symbol = "[➜](green)";
      character.error_symbol = "[➜](bold red)";
      git_branch.symbol = " ";
      git_commit.tag_symbol = " ";
      git_status.format = "([$all_status]($style))";
      git_status.conflicted = " ";
      git_status.untracked = " ";
      git_status.modified = " ";
      git_status.staged = " ";
      git_status.deleted = " ";
      git_status.renamed = " ";
      git_status.stashed = " ";
    };
  };
}
