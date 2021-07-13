{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    terraform
    imagemagick
    ffmpeg
    flyctl
    magic-wormhole
    pngquant
    ripgrep
    httpie
    curl
    sd
  ];
}
