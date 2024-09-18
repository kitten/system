{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.development;
in {
  options.modules.development.js = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable JS tools.";
      type = types.bool;
    };
  };

  config = mkIf cfg.js.enable {
    environment.variables = {
      PNPM_HOME = "$HOME/.local/share/pnpm";
      BUN_RUNTIME_TRANSPILER_CACHE_PATH = "$HOME/.cache/bun/install/cache/@t@";
      COREPACK_ENABLE_AUTO_PIN = "0";
    };

    environment.systemPackages = (with pkgs; [
      bun
      corepack_22
      nodejs_22
    ]);

    environment.interactiveShellInit = ''
      export PATH=./node_modules/.bin:$HOME/.local/share/pnpm:$PATH
    '';
  };
}
