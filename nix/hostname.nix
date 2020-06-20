{ lib, ... }:

let

  inherit (lib) maybeEnv fileContents;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isLinux isDarwin;

in

maybeEnv "HOST" (fileContents (
  if !isDarwin then
    /etc/hostname
  else
    derivation {
      name = "hostname";
      system = builtins.currentSystem;
      builder = "/bin/sh";
      args = [ "-c" "/usr/sbin/scutil --get LocalHostName > $out" ];
    }
))
