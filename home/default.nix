{ ... }:

{
  imports = [
    ./secrets.nix
    ./git.nix
    ./zsh.nix
    ./tmux.nix
    ./wezterm
    ./npm
    ./gpg
  ];
}
