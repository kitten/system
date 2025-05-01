{ lib, pkgs, config, user, ... }:

with lib;
let
  cfgRoot = config.modules.server;
  cfg = config.modules.server.docker;
in {
  options.modules.server.docker = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable Docker.";
      type = types.bool;
    };
  };

  config = mkIf (cfg.enable && cfgRoot.enable) {
    virtualisation.docker.enable = true;

    environment.systemPackages = with pkgs; [
      docker-compose
    ];

    users.extraGroups.docker.members = [ user ];
  };
}
