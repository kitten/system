{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

with lib;
let
  cfg = config.modules.nvim;
  neovim = inputs.system-nvim.packages.${pkgs.system}.neovim;
  vim = pkgs.writeShellScriptBin "vim" ''exec ${neovim}/bin/nvim "$@"'';
  vi = pkgs.writeShellScriptBin "vi" ''exec ${neovim}/bin/nvim "$@"'';
in
{
  options.modules.nvim = {
    enable = mkOption {
      default = true;
      description = "Neovim";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    environment.variables = {
      EDITOR = "vim";
    };

    environment.systemPackages = with pkgs; [
      ripgrep
      fd
      bat
      neovim
      vim
      vi
    ];
  };
}
