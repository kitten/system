{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    magic-wormhole
    pngquant
    ripgrep
    httpie
    curl
    sd
  ];
}
