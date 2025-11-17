{ lib, config, hostname, helpers, pkgs, ... }:

with lib;
let
  address = config.modules.router.adress;
  cfg = config.modules.server;
in helpers.linuxAttrs {
  options.modules.server.tangled = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable Tangled Knot.";
      type = types.bool;
    };

    owner = mkOption {
      default = "did:plc:726afsuwa5x6qaytybar3bfs";
      type = types.str;
    };

    hostname = mkOption {
      default = "knot.kitten.sh";
      type = types.str;
    };
  };

  config = mkIf (cfg.enable && cfg.tangled.enable) {
    services.tangled.knot = {
      enable = true;
      openFirewall = true;
      server = {
        hostname = cfg.tangled.hostname;
        owner = cfg.tangled.owner;
      };
    };

    programs.git = {
      enable = true;
      config = {
        gpg.program = "${pkgs.gnupg}/bin/gpg";
        receive = {
          advertisePushOptions = true;
          denyFastForwards = false;
          fsckObjects = true;
          autogc = true;
        };
        include.path = config.age.secrets."gitconfig.private".path;
      };
    };

    age.secrets."gitconfig.private" = let
      user = config.services.tangled.knot.gitUser;
    in {
      symlink = false;
      path = "/etc/gitconfig.private";
      file = ./encrypt/gitconfig.age;
      owner = user;
      group = user;
      mode = "0444";
    };
  };
}
