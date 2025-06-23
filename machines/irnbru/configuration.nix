{ pkgs, ... }:

{
  imports = [ ];

  modules = {
    server = {
      enable = true;
      sshd.enable = true;
      tailscale.enable = true;
    };
  };
}
