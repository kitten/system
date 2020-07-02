{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ripgrep
    httpie
    curl
    sd
  ];
}
