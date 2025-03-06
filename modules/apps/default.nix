{ lib, helpers, ... }:

with lib; {
  options.modules.apps = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable Apps options.";
      type = types.bool;
    };
  };

  config.modules.apps = {
    enable = if helpers.isLinux then (mkDefault false) else (mkForce false);
  };
} // helpers.linuxAttrs {
  imports = [
    ./games.nix
    ./nix-ld.nix
  ];
}
