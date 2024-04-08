{ pkgs, ... }:

{
  systemd.services.hd-idle = {
    description = "External HD spin down daemon";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      ExecStart = "${pkgs.hd-idle}/bin/hd-idle -i 600";
    };
  };
}
