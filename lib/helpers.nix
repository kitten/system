{ lib, system }:

let
  inherit (lib.systems.elaborate { inherit system; }) isDarwin isLinux;
in {
  inherit system;
  inherit isLinux isDarwin;
  linuxAttrs = lib.attrsets.optionalAttrs isLinux;
  darwinAttrs = lib.attrsets.optionalAttrs isDarwin;
  mkIfLinux = lib.mkIf isLinux;
  mkIfDarwin = lib.mkIf isDarwin;
}
