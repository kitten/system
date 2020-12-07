{ cfg, pkgs, ... }:

{
  environment.systemPackages = (with pkgs; [
    nodejs
    yarn
  ]);

  environment.interactiveShellInit = ''
    export PATH=$HOME/.yarn/bin:$PATH
  '';
}
