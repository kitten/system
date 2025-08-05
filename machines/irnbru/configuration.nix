{ pkgs, ... }:

{
  imports = [ ];

  modules = {
    vram = {
      wiredLimit = 8;
      wiredLowWatermark = 20;
    };
    server = {
      enable = true;
      sshd.enable = true;
    };
  };
}
