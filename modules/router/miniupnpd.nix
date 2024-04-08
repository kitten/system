{ ... }:

{
  services.miniupnpd = {
    enable = true;
    upnp = true;
    natpmp = true;
    internalIPs = [ "intern0" ];
    externalInterface = "extern0";
    appendConfig = ''
      ext_ip=137.220.98.13
      secure_mode=yes
      notify_interval=60
      clean_ruleset_interval=600
      uuid=78b8b903-83c1-4036-8fcd-f64aee25baca
      allow 1024-65535 10.0.0.0/24 1024-65535
      deny 0-65535 0.0.0.0/0 0-65535
    '';
  };
}
