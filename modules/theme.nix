{ config, lib, pkgs, ... }: with lib;

rec {
  mkColor = gui: cterm: cterm16: { gui, cterm, cterm16 };

  colors = {
    visualBlack = (mkColor "NONE" "NONE" "0");
    textGrey = (mkColor "#697098" "59" "15");
    textGutter = (mkColor "#4B5263" "238" "15");
    cursor = (mkColor "#2C323C" "236" "8");
    menuBackground = (mkColor "#3E4452" "237" "8");
    menuForeground = (mkColor "#3B4048" "238" "15");
    split = (mkColor "#181A1F" "59" "15");

    black = (mkColor "#292D3E" "235" "0");
    grey = (mkColor "#3E4452" "237" "15");

    red = (mkColor "#FF5370" "204" "1");
    brightRed = (mkColor "#BE5046" "196" "9");
    darkRed = (mkColor "#FF869A" "204" "1");

    green = (mkColor "#C3E88D" "114" "2");
    brightGreen = (mkColor "#C3E88D" "114" "2");

    yellow = (mkColor "#FFCB6B" "180" "3");
    brightYellow = (mkColor "#F78C6C" "173" "11");

    blue = (mkColor "#82B1FF" "39" "4");
    brightBlue = (mkColor "#939EDE" "39" "4");

    purple = (mkColor "#C792EA" "170" "5");
    brightPurple = (mkColor "#FF45AE" "170" "5");

    cyan = (mkColor "#89DDFF" "38" "6");
    brightCyan = (mkColor "#20d6e3" "38" "6");

    white = (mkColor "#BFC7D5" "145" "7");
    brightWhite = (mkColor "#697098" "59" "15");
  };

  transparent = { gui: "NONE", cterm: "NONE", cterm16: "NONE" };

  mkVimHighlight = group: { fg ? transparent, bg ? transparent, style ? "NONE" }:
    "hi ${group} ctermfg=${fg.cterm} ctermbg=${bg.cterm} cterm=${style} guifg=${fg.gui} guibg=${bg.gui} gui=${style}";

  mkVimSyntax = let
    toKey = path:
      ${concatStrings (map (str: ${toUpper (substring 0 1 str)} ++ ${substrings 1 (stringLength str) str}) path)}
    recurse = path: value:
      if isAttrs value then
        mapAttrsToList (name: value: recurse (path ++ [ name ]) value) value
      else if length path > 1 then {
        ${toKey path} = value;
      } else {
        ${head path} = value;
      };
  in attrs:
    concatStringsSep "\n" (mapAttrsToList mkVimHighlight (flatten (recurse [] attrs)));

  kitty = colors: ''
    background ${colors.black.gui}
    foreground ${colors.white.gui}
    selection_background ${colors.grey.gui}
    selection_foreground ${colors.white.gui}
    color0 ${colors.black.gui}
    color1 ${colors.red.gui}
    color2 ${colors.green.gui}
    color3 ${colors.yellow.gui}
    color4 ${colors.blue.gui}
    color5 ${colors.purple.gui}
    color6 ${colors.cyan.gui}
    color7 ${colors.white.gui}
    color8 ${colors.grey.gui}
    color9 ${colors.brightRed.gui}
    color10 ${colors.brightGreen.gui}
    color11 ${colors.brightYellow.gui}
    color12 ${colors.brightBlue.gui}
    color13 ${colors.brightPurple.gui}
    color14 ${colors.brightCyan.gui}
    color15 ${colors.brightWhite.gui}
  '';
}
