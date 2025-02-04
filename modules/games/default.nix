{ lib, config, ... }:

with lib; let
  cfg = config.modules.games;
in {
  options.modules.games = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable game server options.";
      type = types.bool;
    };

    datadir = mkOption {
      type = types.path;
      default = "/var/lib/games";
      description = "Base directory for all game servers created with this module.";
      example = "/mnt/nfs/steam";
    };

    user = mkOption {
      type = types.str;
      default = "games";
      description = "User to use when running game servers and creating top-level resources";
    };

    group = mkOption {
      type = types.str;
      default = cfg.user;
      defaultText = literalExpression "\${cfg.user}";
      description = "Group to use when running game servers";
    };
  };

  config = mkIf cfg.enable {
    users.users."${cfg.user}" = {
      home = "${cfg.datadir}";
      group = cfg.group;
      isSystemUser = true;
      createHome = true;
      homeMode = "750";
    };

    users.groups."${cfg.group}" = {};

    systemd.tmpfiles.rules = [
      "d ${cfg.datadir}/.steam 0755 ${cfg.user} ${cfg.group} - -"
    ];
  };

  imports = [
    ./palworld.nix
  ];
}
