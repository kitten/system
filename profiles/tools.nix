{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    imagemagick
    ffmpeg
    pngquant
    ripgrep
    xh
    curl
    sd
    awscli
  ];
}
