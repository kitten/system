{ pkgs, helpers, ... }:

helpers.darwinAttrs {
  environment.systemPackages = [
    pkgs.cocoapods
  ];
}
