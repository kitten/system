{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pngquant
    ripgrep
    httpie
    curl
    sd
  ];
}
