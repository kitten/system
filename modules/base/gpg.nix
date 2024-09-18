{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.gpg;
in {
  options.modules.gpg = {
    enable = mkEnableOption "GnuPG";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.gnupg
    ];

    programs.gnupg = {
      agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };
  };
}
