{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;

    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -l";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      add_newline = false;
      character.symbol = "➜";
      aws.disabled = true;
      cmd_duration.disabled = true;
    };
  };
}
