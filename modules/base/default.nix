{ ... }:

{
  imports = [
    ./nix-config.nix
    ./certs.nix
    ./shell.nix
    ./linux.nix
    ./macos.nix
    ./macos-vram.nix
  ];
}
