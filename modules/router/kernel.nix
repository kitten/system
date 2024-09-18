{ lib, config, ... }:

with lib;
let
  cfg = config.modules.router;
in {
  options.modules.router = {
    tweakKernel = mkOption {
      default = cfg.enable;
      description = "Whether to tweak kernel configuration";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    boot.initrd.systemd = {
      enable = true;
      network.enable = true;
    };

    boot.kernel.sysctl = mkIf cfg.tweakKernel {
      "net.core.somaxconn" = 4096;
      "net.core.netdev_max_backlog" = 2000;

      "net.core.rmem_default" = 1048576;
      "net.core.rmem_max" = 26214400;
      "net.core.wmem_default" = 1048576;
      "net.core.wmem_max" = 16777216;
      "net.core.optmem_max" = 65536;

      "net.ipv4.tcp_rmem" = "4096 1048576 2097152";
      "net.ipv4.tcp_wmem" = "4096 65536 16777216";

      "net.ipv4.tcp_max_syn_backlog" = 8192;

      "net.ipv4.udp_rmem_min" = 8192;
      "net.ipv4.udp_wmem_min" = 8192;

      "net.ipv4.tcp_fastopen" = 3;

      "net.ipv4.tcp_max_tw_buckets" = 2000000;
      "net.ipv4.tcp_tw_reuse" = true;
      "net.ipv4.tcp_slow_start_after_idle" = false;
      "net.ipv4.tcp_mtu_probing" = true;

      "net.ipv4.tcp_rfc1337" = true;
      "net.ipv4.tcp_fin_timeout" = 10;

      "net.ipv4.tcp_keepalive_time" = 60;
      "net.ipv4.tcp_keepalive_intvl" = 10;
      "net.ipv4.tcp_keepalive_probes" = 6;

      "net.core.default_qdisc" = "cake";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_syncookies" = true;

      "net.ipv6.conf.all.forwarding" = true;
      "net.ipv6.conf.all.use_tempaddr" = false;
      "net.ipv6.conf.all.autoconf" = false;
      "net.ipv6.conf.all.accept_ra" = false;

      "kernel.kptr_restrict" = 2;
      "kernel.dmesg_restrict" = 0;
      "kernel.sysrq" = 4;
      "kernel.unprivileged_bpf_disabled" = true;
      "kernel.perf_event_paranoid" = 3;
      "kernel.yama.ptrace_scope" = 2;
      "kernel.kexec_load_disabled" = true;
      "net.core.bpf_jit_harden" = 2;
      "dev.tty.ldisc_autoload" = false;
    };
  };
}
