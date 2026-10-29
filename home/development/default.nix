{ lib, ... }:

with lib; {
  options.modules.development = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable Development options.";
      type = types.bool;
    };
  };

  imports = [
    ./instructions.nix
    ./claude.nix
    ./codex.nix
    ./cursor.nix
    ./grok.nix
    ./js.nix
    ./react-native.nix
    ./terraform.nix
    ./zig.nix
    ./t3code.nix
  ];
}
