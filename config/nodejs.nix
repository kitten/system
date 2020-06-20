{ cfg, pkgs, pkgs-unstable, ... }:

{
  environment.systemPackages =
    (with pkgs-unstable;
      let nodejs = nodejs-14_x;
      in [
        nodejs
        (yarn.override { inherit nodejs; })
      ]
    );

  environment.interactiveShellInit = ''
    export PATH=$HOME/.yarn/bin:$PATH
  '';
}
