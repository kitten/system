{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;

    enableCompletion = false;

    shellAliases = {
      nix-encrypt = "openssl enc -e -aes-256-cbc -pbkdf2 -salt -base64 -kfile ${/usr/local/secret}";
      ls = "ls --color=auto";
      ll = "ls -l";
      http = "xh";
    };

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
    };
  };
}
