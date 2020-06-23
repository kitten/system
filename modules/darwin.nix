{ options, pkgs, ... }:

let
  inherit (import ../nix/channels.nix) __nixPath;
in {
  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.bash.enable = true;

  # Recreate /run/current-system symlink after boot.
  services.activate-system.enable = true;

  # Auto-upgrade and manage nix with nix-darwin
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;
}
