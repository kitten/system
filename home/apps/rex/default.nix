{ lib, config, helpers, pkgs, ... } @ inputs:

with lib;
let
  inherit (import ../../../lib/colors.nix inputs) hex;
  cfg = config.modules.apps.rex;
  palette = with hex; [ black red green yellow blue magenta aqua white grey brightRed brightGreen orange brightBlue pink cyan muted ];
  color = value: {
    red = (fromHexString (substring 0 2 value)) / 255.0;
    green = (fromHexString (substring 2 2 value)) / 255.0;
    blue = (fromHexString (substring 4 2 value)) / 255.0;
    alpha = 1;
    colorSpace = "display-p3";
  };
  theme = {
    id = "custom-home-manager";
    name = "Home Manager";
    appearance = "dark";
    createdAt = 0;
    source.ghosttyFile.fileName = "Home Manager";
    palette = (mapAttrs (_: color) {
      background = hex.black;
      foreground = hex.white;
      cursor = hex.white;
      cursorText = hex.grey;
      selectionBackground = hex.cursor;
      selectionForeground = hex.white;
    }) // {
      ansi = map color palette;
      paletteBase = {};
      paletteOverrides = {};
      paletteHarmonious = true;
      paletteGenerate = true;
    };
  };
  themes = pkgs.writeText "rex-themes.json" (builtins.toJSON [ theme ]);
in {
  options.modules.apps.rex = {
    enable = mkEnableOption "Rex configuration (the app is installed separately)";
    font_size = mkOption {
      default = config.modules.apps.ghostty.font_size;
      type = types.either types.int types.float;
      description = "Rex font size in points.";
    };
  };

  config = mkIf (config.modules.apps.enable && cfg.enable) (mkMerge [
    {
      xdg.configFile."rex/init.lua" = {
        source = ./init.lua;
        # Rex reads configuration at server startup, rather than watching the file.
        onChange = optionalString helpers.isDarwin ''
          rex_bin=${escapeShellArg "${config.home.homeDirectory}/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex"}
          if [ -x "$rex_bin" ] && "$rex_bin" --autostart=false api call server.status >/dev/null 2>&1; then
            run "$rex_bin" --autostart=false config reload || echo "Rex config reload failed; continuing Home Manager activation." >&2
          fi
        '';
      };
    }
    (helpers.mkIfDarwin {
      targets.darwin.defaults."com.superlogical.rex" = {
        "Workspace.appearance" = "dark";
        "Workspace.darkThemeID" = theme.id;
        "Workspace.terminalFontName" = "Dank Mono";
        "Workspace.terminalFallbackFontNames" = [ "codicon" ];
        "Workspace.terminalFontPointSize" = cfg.font_size;
        "Workspace.terminalImproveTextContrast" = false;
        "Workspace.terminalCursorBlinkIntervalMilliseconds" = 0;
        "Workspace.terminalCursorBlinkUsesCustomInterval" = false;
        "Workspace.paneDensity" = "compact";
        "Workspace.inactivePaneFadeMode" = "text";
        "Workspace.shellIconTheme" = "themed";
        "Workspace.tabIconTintMode" = "off";
      };
      home.activation.rexTheme = hm.dag.entryAfter [ "setDarwinDefaults" ] ''
        # Rex stores JSON as NSData, which targets.darwin.defaults cannot express.
        # Own the whole list, just as targets.darwin.defaults owns other settings.
        rex_themes_hex=$(/usr/bin/od -An -v -tx1 ${themes} | /usr/bin/tr -d ' \n')
        run /usr/bin/defaults write com.superlogical.rex Workspace.customThemes -data "$rex_themes_hex"
      '';
    })
  ]);
}
