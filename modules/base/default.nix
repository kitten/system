{ ... }:

{
  imports = [
    ./nix-config.nix
    ./certs.nix
    ./shell.nix
    ./linux.nix
    ./macos.nix
  ];
}
