{ ... }:

{
  imports = [
    ./shell.nix
    ./nodejs.nix
    ./postgres.nix
    ./mysql.nix
    ./gpg.nix
    ./nvim
    ./fonts
  ];
}
