{ pkgs, ... }:

{
  imports = [ ];

  modules = {
    nvim.enable = true;
  };

  environment.systemPackages = with pkgs; [
    google-cloud-sdk
    watchman
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

    jq
    yq
  ];
}
