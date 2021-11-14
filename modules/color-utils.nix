let
  inherit (import ../nix/channels.nix) __nixPath nixPath;
  lib = import <nixpkgs/lib>;

  inherit (lib.strings) concatStrings;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.lists) last init;
  inherit (builtins) hasAttr isAttrs length head concatStringsSep;
in rec {
  mkColor = gui: cterm: cterm16: { gui=gui; cterm=cterm; cterm16=cterm16; };
  transparent = (mkColor "NONE" "NONE" "0");
  mkHighlight = { fg ? transparent, bg ? transparent, style ? "NONE" }: { fg=fg; bg=bg; style=style; };
  mkVimHighlight = group: { fg ? transparent, bg ? transparent, style ? "NONE" }:
    "highlight ${group} guifg=${fg.gui} guibg=${bg.gui} gui=${style} ctermfg=${fg.cterm} ctermbg=${bg.cterm} cterm=${style}";
  mkLuaVariable = name: { gui, ... }: "${name} = \"${gui}\",";

  mkVimTerminalSyntax = attrs:
    (if hasAttr "terminal" attrs then ''
      if has("nvim")
        let g:terminal_color_0 = "${attrs.terminal.black.fg.gui}"
        let g:terminal_color_1 = "${attrs.terminal.red.fg.gui}"
        let g:terminal_color_2 = "${attrs.terminal.green.fg.gui}"
        let g:terminal_color_3 = "${attrs.terminal.yellow.fg.gui}"
        let g:terminal_color_4 = "${attrs.terminal.blue.fg.gui}"
        let g:terminal_color_5 = "${attrs.terminal.purple.fg.gui}"
        let g:terminal_color_6 = "${attrs.terminal.cyan.fg.gui}"
        let g:terminal_color_7 = "${attrs.terminal.white.fg.gui}"
        let g:terminal_color_8 = "${attrs.terminal.grey.fg.gui}"
        let g:terminal_color_9 = "${attrs.terminal.brightRed.fg.gui}"
        let g:terminal_color_10 = "${attrs.terminal.brightGreen.fg.gui}"
        let g:terminal_color_11 = "${attrs.terminal.brightYellow.fg.gui}"
        let g:terminal_color_12 = "${attrs.terminal.brightBlue.fg.gui}"
        let g:terminal_color_13 = "${attrs.terminal.brightPurple.fg.gui}"
        let g:terminal_color_14 = "${attrs.terminal.brightCyan.fg.gui}"
        let g:terminal_color_15 = "${attrs.terminal.brightWhite.fg.gui}"
        let g:terminal_color_background = "${attrs.terminal.background.fg.gui}"
        let g:terminal_color_foreground = "${attrs.terminal.foreground.fg.gui}"
      endif
    '' else "");

  mkVimHardlineColors = colors:
    with colors; ''
      {
        text = {gui = "${gutter.gui}", cterm = "${gutter.cterm}", cterm16 = "${gutter.cterm16}"},
        normal = {gui = "${green.gui}", cterm = "${green.cterm}", cterm16 = "${green.cterm16}"},
        insert = {gui = "${blue.gui}", cterm = "${blue.cterm}", cterm16 = "${blue.cterm16}"},
        replace = {gui = "${yellow.gui}", cterm = "${yellow.cterm}", cterm16 = "${yellow.cterm16}"},
        inactive_comment = {gui = "${brightWhite.gui}", cterm = "${brightWhite.cterm}", cterm16 = "${brightWhite.cterm16}"},
        inactive_cursor = {gui = "NONE", cterm = "NONE", cterm16 = "0"},
        inactive_menu = {gui = "${split.gui}", cterm = "${split.cterm}", cterm16 = "${split.cterm16}"},
        visual = {gui = "${brightCyan.gui}", cterm = "${brightCyan.cterm}", cterm16 = "${brightCyan.cterm16}"},
        command = {gui = "${brightPurple.gui}", cterm = "${brightPurple.cterm}", cterm16 = "${brightPurple.cterm16}"},
        alt_text = {gui = "${darkWhite.gui}", cterm = "${darkWhite.cterm}", cterm16 = "${darkWhite.cterm16}"},
        warning = {gui = "${brightYellow.gui}", cterm = "${brightYellow.cterm}", cterm16 = "${brightYellow.cterm16}"},
      }
    '';

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

  mkVimSyntax = let
    recurse = path: value:
      if isAttrs value && !(hasAttr "fg" value) && !(hasAttr "bg" value) && !(hasAttr "style" value) then
        mapAttrsToList
          (name: value: recurse (path ++ (if name != "base" then [name] else [])) value)
          value
      else {
        ${concatStrings path} = value;
      };
    toFlatAttrs = attrs:
      lib.foldl lib.recursiveUpdate {} (lib.flatten (recurse [] attrs));
  in name: attrs:
    ''
    highlight clear

    if exists("syntax_on")
      syntax reset
    endif

    set t_Co=256
    let g:colors_name="${name}"

    ${concatStringsSep "\n" (mapAttrsToList mkVimHighlight (toFlatAttrs attrs))}
    '' + (mkVimTerminalSyntax attrs) + "\nset background=dark";
}
