{ config, lib, ... }:

with lib;
let
  cfg = config.modules.router;
  blcfg = cfg.nftables.blocklist;
  blSetV4 = "blocklist_v4";
  blSetV6 = "blocklist_v6";

  extern = cfg.interfaces.external;
  intern = cfg.interfaces.internal;
  trustedInterfaces = config.networking.firewall.trustedInterfaces;
  internalInterfaces = lists.remove "lo" trustedInterfaces;

  concatIfnames = strings.concatMapStringsSep ", " strings.escapeNixIdentifier;

  capturePortsRules =
    strings.concatStringsSep "\n"
      (builtins.map (port: ''
        iifname { ${concatIfnames internalInterfaces} } meta l4proto { tcp, udp } th dport ${toString port} redirect to ${toString port}
      '') cfg.nftables.capturePorts);

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
        default = [ 53 ];
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
        content = let
          inherit (config.networking.firewall) allowedTCPPorts allowedUDPPorts;
          tcpAccept = let
            tcpPorts = concatMapStringsSep ", " (x: toString x) allowedTCPPorts;
          in optionalString (allowedTCPPorts != []) ''
            tcp dport {${tcpPorts}} ct state new meter tcp-conncount { ip saddr . tcp dport ct count over 150 } counter drop
            tcp dport {${tcpPorts}} ct state new meter tcp6-conncount { ip6 saddr . tcp dport ct count over 150 } counter drop
            tcp dport {${tcpPorts}} ct state new accept
          '';
          udpAccept = let
            udpPorts = concatMapStringsSep ", " (x: toString x) allowedUDPPorts;
          in optionalString (allowedUDPPorts != []) ''
            udp dport {${udpPorts}} ct state new meter udp-conncount { ip saddr . udp dport ct count over 150 } counter drop
            udp dport {${udpPorts}} ct state new meter udp6-conncount { ip6 saddr . udp dport ct count over 150 } counter drop
            udp dport {${udpPorts}} ct state new accept
          '';
          blocklistSets = optionalString blcfg.enable ''
            set ${blSetV4} {
              type ipv4_addr
              flags interval
              auto-merge
            }
            set ${blSetV6} {
              type ipv6_addr
              flags interval
              auto-merge
            }
          '';
          blocklistRules = optionalString blcfg.enable ''
            ip saddr @${blSetV4} counter drop
            ip6 saddr @${blSetV6} counter drop
          '';
        in ''
          ${blocklistSets}

          chain prerouting {
            type nat hook prerouting priority dstnat; policy accept;
            ${capturePortsRules}
          }

          chain postrouting {
            type nat hook postrouting priority srcnat; policy accept;
            oifname != { ${concatIfnames trustedInterfaces} } meta protocol ip masquerade
          }

          chain input {
            type filter hook input priority 0; policy drop;
            ct state { established, related } accept
            ct state invalid drop

            iifname { ${concatIfnames trustedInterfaces} } accept

            ${blocklistRules}

            tcp flags & (fin|syn|rst|ack) != syn ct state new counter drop
            tcp flags & (fin|syn|rst|psh|ack|urg) == fin|syn|rst|psh|ack|urg counter drop
            tcp flags & (fin|syn|rst|psh|ack|urg) == 0x0 counter drop

            ip protocol icmp \
              icmp type { destination-unreachable, time-exceeded } \
              accept

            ip protocol icmp \
              icmp type { echo-reply, echo-request } \
              limit rate 5/second burst 10 packets accept

            meta l4proto ipv6-icmp \
              icmpv6 type { destination-unreachable, packet-too-big, time-exceeded, parameter-problem, \
                            nd-neighbor-solicit, nd-neighbor-advert, nd-router-solicit, nd-router-advert } \
              accept

            meta l4proto ipv6-icmp \
              icmpv6 type { echo-request, echo-reply } \
              limit rate 5/second burst 10 packets accept

            # Layer 1: Global cap on all new WAN connections (single counter, cheapest check)
            ct state new limit rate over 200/second burst 400 packets counter drop

            # Layer 2: Per-source-IP rate limit (hash lookup, bounded by layer 1)
            ct state new meter wan-limit { ip saddr limit rate over 30/second burst 60 packets } counter drop
            ct state new meter wan-limit6 { ip6 saddr limit rate over 30/second burst 60 packets } counter drop

            # Layer 3: Global TCP SYN limit (caps new TCP within the layer 1 budget)
            tcp flags syn ct state new limit rate over 100/second burst 200 packets counter drop

            iifname ${extern.name} udp dport dhcpv6-client ct state new accept

            # Layer 4: Per-source-IP per-port concurrent connection limit (ct count, most expensive)
            ${tcpAccept}
            ${udpAccept}

            # Limit reject responses to reduce scanner feedback; remainder dropped by policy
            limit rate 5/second burst 10 packets counter reject with icmpx type port-unreachable
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
            type filter hook input priority 0; policy drop;
            iifname { ${concatIfnames trustedInterfaces} } accept
            limit rate 1/second burst 2 packets accept
          }

          chain output {
            type filter hook output priority 0; policy accept;
          }
        '';
      };

      tables.tagging = mkIf (intern != null) {
        family = "netdev";
        content = ''
          chain lan {
            type filter hook ingress device ${intern.name} priority -150; policy accept;
            jump tags
          }

          chain tags {
            ip dscp set cs0
            ip6 dscp set cs0

            udp sport 53 ip dscp set cs5
            tcp sport 853 ip dscp set cs5
            udp sport 123 ip dscp set cs5
            tcp dport {80, 443} ip dscp set cs3

            udp dport 41641 ip dscp set cs4
            udp dport {3478-3479, 19302-19309} ip dscp set cs4
            udp sport {3478-3479, 19302-19309} ip dscp set cs4
            meta l4proto udp udp dport {3478-3479, 19302-19309} ip6 dscp set cs4
            meta l4proto udp udp sport {3478-3479, 19302-19309} ip6 dscp set cs4
            udp dport {7000-9000, 27000-27200} ip dscp set cs4
            udp sport {7000-9000, 27000-27200} ip dscp set cs4
            meta l4proto udp udp dport {7000-9000, 27000-27200} ip6 dscp set cs4
            meta l4proto udp udp sport {7000-9000, 27000-27200} ip6 dscp set cs4
          }
        '';
      };
    };

  };
}
