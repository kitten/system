{ pkgs, ... }:

{
  imports = [ ];

  modules = {
    nvim.enable = true;
  };

  environment.systemPackages = with pkgs; [
    coreutils
    openssl
    imagemagick
    ffmpeg
    pngquant
    ripgrep
    xh
    curl
    sd
    fd
    cloudflared
    woff2
    temporal
    dive
    caddy
    flyctl
  ];
}
