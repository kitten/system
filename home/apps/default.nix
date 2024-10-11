{ lib, ... }:

with lib; {
  options.modules.apps = {
    enable = mkOption {
      default = true;
      description = "Whether to enable Apps options.";
      type = types.bool;
    };
  };

  imports = [
    ./firefox.nix
    ./obsidian.nix
    ./ollama.nix
    ./minecraft.nix
    ./wezterm
  ];
}
