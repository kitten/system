{ lib, config, pkgs, helpers, ... }:

with lib;
let
  cfg = config.modules.server.t3code;
  logDir = "/var/log/t3code";
  stateDir = "/var/db/t3code";

  rotation = pkgs.writeText "t3code-logrotate.conf" ''
    ${logDir}/*.log {
      size 10M
      rotate 7
      compress
      delaycompress
      missingok
      notifempty
      copytruncate
    }
  '';
in helpers.darwinAttrs {
  config = mkIf (config.modules.server.enable && cfg.enable) {
    # Users exist here; launchd and Home Manager activation run later.
    system.activationScripts.users.text = mkAfter ''
      install -d -o root -g wheel -m 0755 ${logDir}
      install -d -o root -g wheel -m 0700 ${stateDir}
      touch ${logDir}/server.log ${logDir}/launchd.err.log
      chown ${cfg.account}:staff ${logDir}/server.log ${logDir}/launchd.err.log
      chmod 0600 ${logDir}/server.log ${logDir}/launchd.err.log
    '';

    launchd.daemons.t3code-logrotate = {
      command = "${pkgs.logrotate}/bin/logrotate --state ${stateDir}/logrotate.status ${rotation}";
      serviceConfig = {
        Label = "sh.kitten.t3code-logrotate";
        RunAtLoad = true;
        StartInterval = 300;
        Umask = 63;
      };
    };
  };
}
