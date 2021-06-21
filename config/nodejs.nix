{ cfg, pkgs, ... }:

{
  environment.systemPackages = (with pkgs; [
    v8
    nodejs
    yarn
  ]);

  environment.interactiveShellInit = ''
    export PATH=$HOME/.yarn/bin:$PATH
  '';
}
