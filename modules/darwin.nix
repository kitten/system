{ options, pkgs, ... }:

{
  system.stateVersion = 3;
  # Disable path verification of $NIX_PATH
  system.checks.verifyNixPath = false;
  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.bash.enable = true;
  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;
}
