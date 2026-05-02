{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.router;
  blcfg = cfg.nftables.blocklist;
  setV4 = "blocklist_v4";
  setV6 = "blocklist_v6";

  updateScript = let
    v4Urls = concatStringsSep " " (map escapeShellArg blcfg.urls);
    v6Urls = concatStringsSep " " (map escapeShellArg blcfg.urlsV6);
  in pkgs.writeShellApplication {
    name = "nftables-blocklist-update";
    runtimeInputs = with pkgs; [ curl nftables gawk coreutils ];
    text = ''
      dir="$STATE_DIRECTORY"

      nft list tables || exit 0

      fetch() {
        local out="$1"; shift
        local tmp="$dir/.tmp" ok=false
        : > "$tmp"
        for url in "$@"; do
          if curl -sfL --max-time 30 --retry 2 "$url" >> "$tmp"; then
            ok=true
          fi
        done
        if "$ok"; then mv "$tmp" "$out"; else rm -f "$tmp"; fi
      }

      fetch "$dir/v4.json" ${v4Urls}
      fetch "$dir/v6.json" ${v6Urls}

      touch "$dir/v4.json" "$dir/v6.json"
      awk -F'"' '
        BEGINFILE { elems = ""; sep = ""; n = 0 }
        $2 == "cidr" { elems = elems sep $4; sep = ", "; n++ }
        ENDFILE {
          print "flush set inet filter " SET
          if (n) print "add element inet filter " SET " { " elems " }"
          printf "%d %s entries\n", n, SET > "/dev/stderr"
        }
      ' SET=${setV4} "$dir/v4.json" SET=${setV6} "$dir/v6.json" \
        | nft -f -
    '';
  };
in {
  options.modules.router.nftables.blocklist = {
    enable = mkOption {
      default = false;
      description = "Whether to enable IP blocklist using Spamhaus DROP";
      type = types.bool;
    };

    urls = mkOption {
      default = [
        "https://www.spamhaus.org/drop/drop_v4.json"
      ];
      description = "URLs to fetch IPv4 blocklists from (NDJSON with cidr field)";
      type = types.listOf types.str;
    };

    urlsV6 = mkOption {
      default = [
        "https://www.spamhaus.org/drop/drop_v6.json"
      ];
      description = "URLs to fetch IPv6 blocklists from (NDJSON with cidr field)";
      type = types.listOf types.str;
    };
  };

  config = mkIf (cfg.nftables.enable && blcfg.enable) {
    systemd.services.nftables-blocklist = {
      description = "Update nftables IP blocklist";
      after = [ "nftables.service" "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        StateDirectory = "nftables-blocklist";
        ExecStart = getExe updateScript;
      };
    };

    systemd.timers.nftables-blocklist = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 00/12:00:00";
        RandomizedDelaySec = "1h";
        Persistent = true;
      };
    };

    # Re-populate blocklist sets after nftables starts or reloads (flushRuleset clears them)
    systemd.services.nftables.serviceConfig = let
      trigger = "${pkgs.systemd}/bin/systemctl start --no-block nftables-blocklist.service";
    in {
      ExecStartPost = [ trigger ];
      ExecReload = [ trigger ];
    };
  };
}
