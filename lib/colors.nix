{ lib, ... }:

let
  inherit (lib.strings) concatStrings;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.lists) last init;
  inherit (lib.trivial) boolToString;
  inherit (builtins) hasAttr isAttrs length head concatStringsSep isInt isBool;

  mkColor = gui: cterm: cterm16: { gui=gui; cterm=cterm; cterm16=cterm16; };
in rec {
  shell = "rgba(40, 44, 46, 0.6)";
  lightStroke = "rgba(248, 248, 241, 0.2)";
  darkStroke = "rgba(22, 23, 29, 0.2)";

  hex = {
    # for sidebars / sidenavs / passive UI elements
    gutter = "161622";
    # for selection / cursors
    cursor = "242738";
    # for overlays / large popups / hint / codelens UIs
    element = "050B12";
    # for borders and thin lines, e.g. to separate panes
    split = "2A2D46";

    # (ANSI: 0 Black) background colour
    black = "070D14";
    # (ANSI: 7 White) foreground colour, identifiers, variables
    white = "EDF0F2";
    # (ANSI: 8 Bright Black) ghost text / suggestion text
    grey = "323744";
    # (ANSI: 15 Bright White) comment text
    muted = "585D79";

    # (ANSI: 1 Red) conditional, boolean, return keywords
    red = "F84F6B";
    # (ANSI: 9 Bright Red) errors
    brightRed = "E93434";
    # (ANSI: 2 Green) strings
    green = "7DD486";
    # (ANSI: 10 Bright Green) special chars
    brightGreen = "05AE48";
    # (ANSI: 3 Yellow) warnings & structures
    yellow = "D7C046";
    # (ANSI: 11 Bright Yellow) constants & numbers
    orange = "F95A10";
    # (ANSI: 4 Blue) functions, search, and some selections
    blue = "98BDFB";
    # (ANSI: 12 Bright Blue) todos & URL/links
    brightBlue = "6A78F6";
    # (ANSI: 5 Purple) keywords, statements
    magenta = "F651A6";
    # (ANSI: 13 Bright Purple) operators, tags, properties
    pink = "F2B0C0";
    # (ANSI: 6 Cyan) types
    aqua = "14B6C8";
    # (ANSI: 14 Bright Cyan) delimiters & labels
    cyan = "02B394";
  };

  colors = {
    gutter = (mkColor "#${hex.gutter}" 233 15);
    cursor = (mkColor "#${hex.cursor}" 235 8);
    element = (mkColor "#${hex.element}" 233 15);
    split = (mkColor "#${hex.split}" 236 15);

    black = (mkColor "#${hex.black}" 233 0);
    grey = (mkColor "#${hex.grey}" 237 15);

    red = (mkColor "#${hex.red}" 204 1);
    brightRed = (mkColor "#${hex.brightRed}" 203 9);

    green = (mkColor "#${hex.green}" 114 2);
    brightGreen = (mkColor "#${hex.brightGreen}" 35 10);

    yellow = (mkColor "#${hex.yellow}" 221 3);
    orange = (mkColor "#${hex.orange}" 202 11);

    blue = (mkColor "#${hex.blue}" 111 4);
    brightBlue = (mkColor "#${hex.brightBlue}" 105 12);

    pink = (mkColor "#${hex.pink}" 217 5);
    magenta = (mkColor "#${hex.magenta}" 205 13);

    aqua = (mkColor "#${hex.aqua}" 37 6);
    cyan = (mkColor "#${hex.cyan}" 36 14);

    white = (mkColor "#${hex.white}" 255 7);
    muted = (mkColor "#${hex.muted}" 60 15);
  };

  transparent = (mkColor "NONE" "NONE" 0);

  mkHighlight = { fg ? transparent, bg ? transparent, style ? "NONE" }: { fg=fg; bg=bg; style=style; };
  mkLuaVariable = name: { gui, ... }: "${name} = \"${gui}\",";
  mkScssVariable = name: { gui, ... }: "\$color-${name}: ${gui};";

  mkZedStyles = let
    valueToString = value: "${value.gui}";
    isValue = value: isAttrs value && hasAttr "gui" value;
    recurse = path: value:
      if isAttrs value && !(isValue value) then
        mapAttrsToList
          (name: value: recurse (path ++ (if name != "base" then [name] else [])) value)
          value
      else {
        ${concatStringsSep "." path} = valueToString value;
      };
  in
    styles: lib.foldl lib.recursiveUpdate {} (lib.flatten (recurse [] styles));

  mkLuaSyntax = let
    recurse = path: value:
      if isAttrs value && !(hasAttr "gui" value) then
        mapAttrsToList
          (name: value: recurse (path ++ (if name != "base" then [name] else [])) value)
          value
      else {
        ${concatStrings path} = value;
      };
    toFlatAttrs = attrs:
      lib.foldl lib.recursiveUpdate {} (lib.flatten (recurse [] attrs));
  in colors:
    ''
    { ${concatStringsSep "\n" (mapAttrsToList mkLuaVariable (toFlatAttrs colors))} }
    '';

  mkScssSyntax = let
    recurse = path: value:
      if isAttrs value && !(hasAttr "gui" value) then
        mapAttrsToList
          (name: value: recurse (path ++ (if name != "base" then [name] else [])) value)
          value
      else {
        ${concatStrings path} = value;
      };
    toFlatAttrs = attrs:
      lib.foldl lib.recursiveUpdate {} (lib.flatten (recurse [] attrs));
  in colors:
    (concatStringsSep "\n" (mapAttrsToList mkScssVariable (toFlatAttrs colors)));
}
