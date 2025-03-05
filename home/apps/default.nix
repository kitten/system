{ lib, ... }:

with lib; {
  options.modules.apps = {
    enable = mkOption {
      default = false;
      description = "Whether to enable Apps options.";
      type = types.bool;
    };
  };

  imports = [
    ./discord.nix
    ./firefox.nix
    ./zen-browser.nix
    ./obsidian.nix
    ./ollama.nix
    ./minecraft.nix
    ./ghostty.nix
    ./wezterm
  ];
}
