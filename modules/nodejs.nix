{ pkgs, ... }:

{
  environment.variables.PNPM_HOME = "$HOME/.local/share/pnpm";

  environment.systemPackages = (with pkgs; [
    pkgs.nodePackages.pnpm
    pkgs.nodejs-18_x
    yarn
  ]);

  environment.interactiveShellInit = ''
    export PATH=./node_modules/.bin:$HOME/.yarn/bin:$HOME/.local/share/pnpm:$PATH
  '';
}
