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
    ./claude.nix
    ./js.nix
    ./react-native.nix
    ./terraform.nix
    ./zig.nix
  ];
}
