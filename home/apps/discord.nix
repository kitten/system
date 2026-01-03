{ lib, config, helpers, pkgs, ... }:

with lib;
let
  cfg = config.modules.apps;
in {
  options.modules.apps.discord = {
    enable = mkOption {
      default = false;
      description = "Whether to enable Discord.";
      type = types.bool;
    };
  };

  config = mkIf (cfg.enable && cfg.discord.enable) (mkMerge [
    {
      home.packages = with pkgs; let
        pkg = vesktop.overrideAttrs (old: {
          # electron builds must be writable
          preBuild = optionalString stdenv.hostPlatform.isDarwin ''
            cp -r ${electron.dist}/Electron.app .
            chmod -R u+w Electron.app
          '' + optionalString stdenv.hostPlatform.isLinux ''
            cp -r ${electron.dist} electron-dist
            chmod -R u+w electron-dist
          '';
          buildPhase = ''
            runHook preBuild
            pnpm build
            pnpm exec electron-builder \
              --dir \
              -c.asarUnpack="**/*.node" \
              -c.electronDist=${if stdenv.hostPlatform.isDarwin then "." else "electron-dist"} \
              -c.electronVersion=${electron.version}
            runHook postBuild
          '';
        });
      in [ pkg ];
    }

    (helpers.mkIfLinux {
      systemd.user.sessionVariables.NIXOS_OZONE_WL = mkDefault 1;
    })
  ]);
}
