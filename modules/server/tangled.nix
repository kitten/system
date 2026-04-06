{ lib, config, hostname, helpers, pkgs, ... }:

with lib;
let
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
    modules.server.backup.paths.tangled = {
      path = "${config.services.tangled.knot.stateDir}/repos";
    };

    services = {
      tangled.knot = {
        enable = true;
        openFirewall = true;
        server = {
          hostname = cfg.tangled.hostname;
          owner = cfg.tangled.owner;
        };
      };

      modules.server.sshd.allowUsers = [ config.services.tangled.knot.gitUser ];
    };

    programs.git = {
      enable = true;
      config = {
        gpg.program = "${pkgs.gnupg}/bin/gpg";
        transfer.fsckObjects = true;
        receive = {
          advertisePushOptions = true;
          denyFastForwards = false;
          denyDeleteCurrent = true;
          fsckObjects = true;
          autogc = true;
          maxInputSize = "500m";
        };
        protocol.version = 2;
        uploadpack = {
          allowFilter = true;
          allowReachableSHA1InWant = true;
          keepAlive = 5;
        };
        core = {
          bigFileThreshold = "50m";
          commitGraph = true;
          multiPackIndex = true;
          packedGitLimit = "256m";
          packedGitWindowSize = "1m";
          deltaBaseCacheLimit = "96m";
        };
        pack = {
          threads = 0;
          windowMemory = "256m";
          window = 25;
        };
        gc = {
          bigPackThreshold = "512m";
          writeCommitGraph = true;
        };
        repack.writeBitmaps = true;
        include.path = config.age.secrets."gitconfig.private".path;
      };
    };

    systemd.services.knot.serviceConfig = {
      MemoryMax = "8G";
      MemoryHigh = "6G";
      CPUWeight = 80;
      TasksMax = 128;
    };

    systemd.services.tangled-motd = {
      description = "Update Tangled MOTD";
      serviceConfig = {
        Type = "oneshot";
        User = config.services.tangled.knot.gitUser;
        ExecStart = let
          stateDir = config.services.tangled.knot.stateDir;
        in pkgs.writeShellScript "tangled-motd" ''
          ${pkgs.fortune-kind}/bin/fortune-kind | ${pkgs.coreutils}/bin/head -1 > "${stateDir}/motd"
        '';
      };
    };

    systemd.timers.tangled-motd = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "hourly";
        Persistent = true;
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
