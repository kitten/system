{ lib, system }:

let
  inherit (lib.systems.elaborate { inherit system; }) isDarwin isLinux;
in {
  inherit isLinux isDarwin;
  linuxAttrs = lib.attrsets.optionalAttrs isLinux;
  darwinAttrs = lib.attrsets.optionalAttrs isDarwin;
}
