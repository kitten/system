{ config, lib, ... }:

let
  trustedInterfaces =
    lib.strings.concatMapStringsSep ", " lib.strings.escapeNixIdentifier config.networking.firewall.trustedInterfaces;
in {
  networking.firewall.checkReversePath = "loose";

  networking.nftables = {
    enable = true;
    checkRuleset = false;
    flushRuleset = true;

    tables.filter = {
      family = "inet";
      content = ''
        chain prerouting {
          type nat hook prerouting priority 0; policy accept;
          iifname { ${trustedInterfaces} } udp dport 53 redirect to 53
          iifname { ${trustedInterfaces} } udp dport 123 redirect to 123
        }

        chain postrouting {
          type nat hook postrouting priority 0; policy accept;
          oifname != { ${trustedInterfaces} } masquerade
        }

        chain input {
          type filter hook input priority 0;
          ct state { established, related } accept
          ct state invalid drop
          iifname { ${trustedInterfaces} } accept
          iifname { ${trustedInterfaces} } pkttype { broadcast, multicast } accept
          tcp flags & (fin|syn|rst|ack) != syn ct state new counter drop
          tcp flags & (fin|syn|rst|psh|ack|urg) == fin|syn|rst|psh|ack|urg counter drop
          tcp flags & (fin|syn|rst|psh|ack|urg) == 0x0 counter drop
          ip protocol icmp \
            icmp type { destination-unreachable, echo-reply, echo-request, source-quench, time-exceeded } \
            accept
          ip6 nexthdr icmpv6 accept
          udp dport 546 ct state { new, untracked } accept
          udp dport dhcpv6-client accept
          udp dport { http, https } ct state new accept
          tcp dport { http, https } ct state new accept
          udp dport 41641 ct state new accept
          reject with icmpx type port-unreachable
        }

        chain forward {
          type filter hook forward priority 0; policy drop;
          ip6 nexthdr ipv6-icmp accept
          udp dport dhcpv6-client accept
          iifname intern0 oifname != intern0 ether saddr == ec:e5:12:1d:23:40 drop # drop tado internet traffic
          iifname { ${trustedInterfaces} } accept
          oifname { ${trustedInterfaces} } ct state { established, related } accept
          ct state invalid drop
        }

        chain output {
          type filter hook output priority 0; policy accept;
          ip6 nexthdr ipv6-icmp accept
          udp dport dhcpv6-client accept
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
          iifname != { ${trustedInterfaces} } limit rate 1/second burst 2 packets accept
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
          type filter hook ingress device intern0 priority -150; policy accept;
          jump tags
        }

        chain wan {
          type filter hook ingress device extern0 priority -149; policy accept;
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
}
