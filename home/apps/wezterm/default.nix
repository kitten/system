{ lib, config, pkgs, helpers, ... } @ inputs:

with lib;
let
  inherit (pkgs) stdenv;
  inherit (import ../../../lib/colors.nix inputs) colors mkLuaSyntax;

  cfg = config.modules.apps;

  wezterm = pkgs.wezterm.overrideAttrs (_: {
    preFixup = optionalString stdenv.isLinux ''
      patchelf \
        --add-needed "${pkgs.libGL}/lib/libEGL.so.1" \
        --add-needed "${pkgs.vulkan-loader}/lib/libvulkan.so.1" \
        $out/bin/wezterm-gui
    '' + lib.optionalString stdenv.isDarwin ''
      mkdir -p "$out/Applications"
      OUT_APP="$out/Applications/WezTerm.app"
      cp -r assets/macos/WezTerm.app "$OUT_APP"
      rm $OUT_APP/*.dylib
      cp -r assets/shell-integration/* "$OUT_APP"
      ln -s $out/bin/{wezterm,wezterm-mux-server,wezterm-gui,strip-ansi-escapes} "$OUT_APP"
    '';
  });

  configStr = ''
    local font_size = ${if helpers.isDarwin then "14" else "12"};
    local is_linux = ${if helpers.isLinux then "true" else "false"};
    local zsh_bin = "${pkgs.zsh}/bin/zsh";
    local colors = ${mkLuaSyntax colors};
  '' + (builtins.readFile ./init.lua);

  shellIntegrationStr = ''
    source "${wezterm}/etc/profile.d/wezterm.sh"
  '';
in {
  options.modules.apps.wezterm = {
    enable = mkOption {
      default = false;
      description = "Whether to enable Wezterm.";
      type = types.bool;
    };
  };

  config = mkIf (cfg.enable && cfg.wezterm.enable) {
    home.packages = [ wezterm ];
    xdg.configFile."wezterm/wezterm.lua".text = configStr;
    programs.zsh.initExtra = shellIntegrationStr;
  };
}
