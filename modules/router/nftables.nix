{ config, lib, ... }:

with lib;
let
  cfg = config.modules.router;

  intern = cfg.interfaces.internal;
  trustedInterfaces = config.networking.firewall.trustedInterfaces;
  internalInterfaces = lists.remove "lo" trustedInterfaces;

  concatIfnames = strings.concatMapStringsSep ", " strings.escapeNixIdentifier;

  capturePortsRules =
    strings.concatStringsSep "\n"
      (builtins.map (port: "  iifname { ${concatIfnames internalInterfaces} } udp dport ${toString port} redirect to ${toString port}") cfg.nftables.capturePorts);

  blockForwardRules =
    if intern != null then
      strings.concatStringsSep "\n"
        (builtins.map (mac: "  iifname ${intern.name} oifname != ${intern.name} ether saddr == ${mac} drop") cfg.nftables.blockForward)
    else "";
in {
  options.modules.router = {
    nftables = {
      enable = mkOption {
        default = cfg.enable;
        description = "Whether to enable Router NFTables config";
        type = types.bool;
      };

      capturePorts = mkOption {
        default = [ 53 123 ];
        description = "Ports to capture and redirect to router";
        type = types.listOf types.int;
      };

      blockForward = mkOption {
        default = [];
        description = "MAC Addresses of devices to block internet access for";
        type = types.listOf types.str;
      };
    };
  };

  config = mkIf cfg.nftables.enable {
    networking.useNetworkd = mkDefault true;
    networking.firewall = {
      enable = mkDefault true;
      checkReversePath = "loose";
    };

    networking.nftables = {
      enable = mkForce true;
      checkRuleset = false;
      flushRuleset = true;

      tables.filter = {
        family = "inet";
        content = ''
          chain prerouting {
            type nat hook prerouting priority 0; policy accept;
            ${capturePortsRules}
          }

          chain postrouting {
            type nat hook postrouting priority 0; policy accept;
            oifname != { ${concatIfnames trustedInterfaces} } masquerade
          }

          chain input {
            type filter hook input priority 0;
            ct state { established, related } accept
            ct state invalid drop
            iifname { ${concatIfnames trustedInterfaces} } accept
            iifname { ${concatIfnames trustedInterfaces} } pkttype { broadcast, multicast } accept
            tcp flags & (fin|syn|rst|ack) != syn ct state new counter drop
            tcp flags & (fin|syn|rst|psh|ack|urg) == fin|syn|rst|psh|ack|urg counter drop
            tcp flags & (fin|syn|rst|psh|ack|urg) == 0x0 counter drop
            ip protocol icmp \
              icmp type { destination-unreachable, echo-reply, echo-request, source-quench, time-exceeded } \
              accept
            meta l4proto ipv6-icmp accept
            ip6 ecn not-ect accept
            udp dport dhcpv6-client ct state { new, untracked } accept
            udp dport 41641 ct state new accept
            reject with icmpx type port-unreachable
          }

          chain forward {
            type filter hook forward priority 0; policy drop;
            ${blockForwardRules}
            iifname { ${concatIfnames trustedInterfaces} } accept
            oifname { ${concatIfnames trustedInterfaces} } ct state { established, related } accept
            ct state invalid drop
          }

          chain output {
            type filter hook output priority 0; policy accept;
            iifname lo accept
            ct state invalid drop
          }
        '';
      };

      tables.arp_filter = {
        family = "arp";
        content = ''
          chain input {
            type filter hook input priority 0; policy accept;
            iifname != { ${concatIfnames trustedInterfaces} } limit rate 1/second burst 2 packets accept
          }

          chain output {
            type filter hook output priority 0; policy accept;
          }
        '';
      };

      tables.tagging = {
        family = "netdev";
        content = ''
          chain lan {
            type filter hook ingress priority -150; policy accept;
            jump tags
          }

          chain tags {
            ip dscp set cs0
            ip6 dscp set cs0

            ip protocol udp udp sport ntp ip dscp set cs5
            ip6 nexthdr udp udp sport ntp ip6 dscp set cs5

            ip saddr {1.1.1.1, 1.0.0.1} ip dscp set cs5
            ip daddr {1.1.1.1, 1.0.0.1} ip dscp set cs5

            tcp dport {http, https} ip dscp set cs3
            tcp sport {http, https} ip dscp set cs3
            ip6 nexthdr tcp tcp dport {http, https} ip6 dscp set cs3
            ip6 nexthdr tcp tcp sport {http, https} ip6 dscp set cs3

            udp dport 41641 ip dscp set cs4 # tailscale
            udp sport 41641 ip dscp set cs4 # tailscale

            # mark some VOIP traffic as flash override (low delay)
            udp dport {3478-3479, 19302-19309} ip dscp set cs4
            udp sport {3478-3479, 19302-19309} ip dscp set cs4
            ip6 nexthdr udp udp dport {3478-3479, 19302-19309} ip6 dscp set cs4
            ip6 nexthdr udp udp sport {3478-3479, 19302-19309} ip6 dscp set cs4
            udp dport {7000-9000, 27000-27200} ip dscp set cs4
            udp sport {7000-9000, 27000-27200} ip dscp set cs4
            ip6 nexthdr udp udp dport {7000-9000, 27000-27200} ip6 dscp set cs4
            ip6 nexthdr udp udp sport {7000-9000, 27000-27200} ip6 dscp set cs4
          }
        '';
      };
    };
  };
}
