{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
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
