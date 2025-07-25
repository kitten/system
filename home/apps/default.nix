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
    ./slack.nix
    ./discord.nix
    ./firefox.nix
    ./chromium.nix
    ./zen-browser.nix
    ./obsidian.nix
    ./ollama.nix
    ./minecraft.nix
    ./ghostty.nix
    ./wezterm
    ./zed-editor
  ];
}
