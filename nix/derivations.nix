let
  lib = import <nixpkgs/lib>;
  pkgs = import <nixpkgs> { system = builtins.currentSystem; };
in {
  copyFiles = name: entries: pkgs.runCommand name { preferLocalBuild = true; allowSubstitutes = false; }
    ''
      mkdir -p $out
      cd $out
      ${lib.concatMapStrings (x: ''
        mkdir -p "$(dirname ${lib.escapeShellArg x.target})"
        cp ${lib.escapeShellArg x.source} ${lib.escapeShellArg x.target}
      '') entries}
    '';
}
