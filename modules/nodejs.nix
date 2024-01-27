{ pkgs, ... }:

{
  environment.variables.PNPM_HOME = "$HOME/.local/share/pnpm";

  environment.systemPackages = (with pkgs; [
    corepack_20
    nodejs_20
  ]);

  environment.interactiveShellInit = ''
    export PATH=./node_modules/.bin:$HOME/.local/share/pnpm:$PATH
  '';
}
