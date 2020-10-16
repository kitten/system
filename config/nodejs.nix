{ cfg, pkgs, pkgs-unstable, ... }:

{
  environment.systemPackages = (with pkgs; [
    nodejs
    yarn
  ]);

  environment.interactiveShellInit = ''
    export PATH=$HOME/.yarn/bin:$PATH
  '';
}
