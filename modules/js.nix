{ pkgs, ... }:

{
  environment.variables = {
    PNPM_HOME = "$HOME/.local/share/pnpm";
    BUN_RUNTIME_TRANSPILER_CACHE_PATH = "$HOME/.cache/bun/install/cache/@t@";
  };

  environment.systemPackages = (with pkgs; [
    bun
    corepack_20
    nodejs_20
  ]);

  environment.interactiveShellInit = ''
    export PATH=./node_modules/.bin:$HOME/.local/share/pnpm:$PATH
  '';
}
