{ lib, ... }:

with lib; {
  options.modules.desktop = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable Deskop options.";
      type = types.bool;
    };
  };

  imports = [
    ./hyprland.nix
    ./theme.nix
    ./tools.nix
  ];
}
