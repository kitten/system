{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.gnupg
  ];

  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
}
