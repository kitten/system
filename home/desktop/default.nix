{ lib, helpers, ... }:

with lib; {
  options.modules.desktop = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable Desktop options.";
      type = types.bool;
    };
  };

  config.modules.desktop = {
    enable = if helpers.isLinux then (mkDefault false) else (mkForce false);
  };
} // helpers.linuxAttrs {
  imports = [
    ./theme.nix
  ];
}
