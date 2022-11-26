{ cfg, pkgs, ... }:

{
  environment.variables.PNPM_HOME = "$HOME/.local/share/pnpm";

  environment.systemPackages = (with pkgs; [
    pkgs.nodePackages.pnpm
    nodejs
    yarn
  ]);

  environment.interactiveShellInit = ''
    export PATH=$HOME/.yarn/bin:$HOME/.local/share/pnpm:$PATH
  '';
}
