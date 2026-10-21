{ lib, config, pkgs, helpers, hostname, ... }:

with lib;
let
  cfgRoot = config.modules.server;
  cfg = config.modules.server.t3code;
  agent = config.modules.agents.${cfg.account};
  home = agent.homeDirectory;
  hm = config.home-manager.users.${cfg.account};
  # Not lib.getExe: nixpkgs' mainProgram is the desktop app (t3code-desktop).
  t3 = "${homeCfg.package}/bin/t3";
  logDir = "/var/log/t3code";
  auth = import ../../../lib/shell-env-wrapper.nix { inherit lib pkgs; };
  envFiles = optional (hm.modules.agent.tokenEnvFile != null) hm.modules.agent.tokenEnvFile
    ++ auth.runtimeFiles "${cfg.account}-t3code" homeCfg.environmentFile config.age.secrets;

  homeCfg = hm.modules.development.t3code;

  shell = "${hm.programs.zsh.package}/bin/zsh";

  withEnv = pkgs.writeShellScript "t3code-env" ''
    set -euo pipefail
    umask 077
    export HOME=${home} USER=${cfg.account} LOGNAME=${cfg.account} LANG=en_US.UTF-8
    export PATH=/usr/bin:/bin:/usr/sbin:/sbin
    # Before the session vars: they're sorted, and NPM_CONFIG_TMP builds on it.
    export XDG_RUNTIME_DIR="$(/usr/bin/getconf DARWIN_USER_TEMP_DIR)"
    set +u
    . ${config.system.build.setEnvironment}
    . ${hm.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh
    set -u
    export SHELL=${shell}
    mkdir -p "$TMPDIR"

    export T3CODE_HOME=${home}/.t3 T3CODE_NO_BROWSER=true
    export T3CODE_TELEMETRY_ENABLED=${boolToString homeCfg.telemetry}
    export GIT_TERMINAL_PROMPT=0 GH_PROMPT_DISABLED=1 GH_NO_UPDATE_NOTIFIER=1

    # agenix installs secrets asynchronously at boot.
    for envFile in ${escapeShellArgs envFiles}; do
      for _ in $(seq 120); do
        [ -r "$envFile" ] && break
        sleep 1
      done
      set -a
      . "$envFile"
      set +a
    done
    export GITHUB_TOKEN="''${GITHUB_TOKEN:-''${GH_TOKEN:-}}"

    exec "$@"
  '';

  # `t3 serve` prints a one-time admin pairing token, URL and QR code at every
  # start; keep them out of the log.
  serve = pkgs.writeShellScript "t3code-serve" ''
    set -euo pipefail
    exec > >(LC_ALL=C ${pkgs.gnugrep}/bin/grep --line-buffered -vE '^(Token|Pairing URL): |█|▀|▄') 2>&1
    exec ${t3} serve --host 0.0.0.0 --port ${toString cfg.port} --base-dir ${home}/.t3
  '';

  shellHelper = pkgs.writeShellScriptBin "t3code-shell" ''
    set -euo pipefail
    if [ "$(id -u)" -ne 0 ]; then exec sudo "$0" "$@"; fi
    [ "$#" -gt 0 ] || set -- ${shell} -l
    cd ${home}
    exec sudo -u ${cfg.account} -H /usr/bin/env -i ${withEnv} "$@"
  '';

  pairHelper = pkgs.writeShellScriptBin "t3code-pair" ''
    exec ${shellHelper}/bin/t3code-shell ${t3} auth pairing create \
      --base-dir ${home}/.t3 --base-url ${cfg.publicUrl} --ttl 10m "$@"
  '';

in helpers.darwinAttrs {
  imports = [ ./lifecycle.nix ];

  options.modules.server.t3code = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable the T3 Code server.";
      type = types.bool;
    };

    account = mkOption {
      default = "agent";
      description = "Agent account to enable and run T3 Code as (modules.agents.<name>).";
      type = types.strMatching "[a-z_][a-z0-9_-]*";
    };

    port = mkOption {
      # Not T3's 3773: a desktop app on the same Mac takes the first free port
      # from 3773, and would grab it while the daemon restarts.
      default = 3780;
      description = "Port of the server, listening on all IPv4 interfaces.";
      type = types.port;
    };

    publicUrl = mkOption {
      default = "http://${hostname}:${toString cfg.port}/";
      defaultText = literalExpression ''"http://''${hostname}:''${toString cfg.port}/"'';
      description = "URL the apps reach the server at; used by t3code-pair.";
      type = types.str;
    };

  };

  config = mkIf (cfgRoot.enable && cfg.enable) {
    modules.agents.${cfg.account} = {
      enable = true;
      home = {
        modules.development.t3code = {
          enable = true;
          desktop.enable = false;
        };
      };
    };

    environment.systemPackages = [ shellHelper pairHelper ];

    power.restartAfterPowerFailure = mkDefault true;

    launchd.daemons.t3code = {
      command = "${withEnv} ${serve}";
      serviceConfig = {
        Label = "sh.kitten.t3code";
        UserName = cfg.account;
        GroupName = "staff";
        WorkingDirectory = home;
        Umask = 63;
        RunAtLoad = true;
        KeepAlive = true;
        ThrottleInterval = 5;
        ExitTimeOut = 90;
        ProcessType = "Interactive";
        StandardOutPath = "${logDir}/server.log";
        StandardErrorPath = "${logDir}/launchd.err.log";
      };
    };

  };
}
