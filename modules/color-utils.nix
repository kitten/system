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

  mkVimLightlineSyntax = name: colors:
    with colors; ''
      let g:lightline#colorscheme#${name}#palette = lightline#colorscheme#flatten({
      \ 'normal': {
      \   'left': [[['${split.gui}', ${split.cterm}], ['${green.gui}', ${green.cterm}], 'bold'], [['${white.gui}', ${white.cterm}], ['${split.gui}', ${split.cterm}]]],
      \   'middle': [[['${white.gui}', ${white.cterm}], ['NONE', 0]]],
      \   'right': [[['${split.gui}', ${split.cterm}], ['${green.gui}', ${green.cterm}], 'bold'], [['${white.gui}', ${white.cterm}], ['${split.gui}', ${split.cterm}]]],
      \   'error': [[['${red.gui}', ${red.cterm}], ['${split.gui}', ${split.cterm}]]],
      \   'warning': [[['${yellow.gui}', ${yellow.cterm}], ['${split.gui}', ${split.cterm}]]]
      \ },
      \ 'inactive': {
      \   'left': [[['${brightWhite.gui}', ${brightWhite.cterm}], ['${split.gui}', ${split.cterm}]], [['${brightWhite.gui}', ${brightWhite.cterm}], ['${split.gui}', ${split.cterm}]]],
      \   'middle': [[['${brightWhite.gui}', ${brightWhite.cterm}], ['NONE', 0]]],
      \   'right': [[['${brightWhite.gui}', ${brightWhite.cterm}], ['${split.gui}', ${split.cterm}]]]
      \ },
      \ 'insert': {
      \   'left': [[['${split.gui}', ${split.cterm}], ['${blue.gui}', ${blue.cterm}], 'bold'], [['${white.gui}', ${white.cterm}], ['${split.gui}', ${split.cterm}]]],
      \   'right': [[['${split.gui}', ${split.cterm}], ['${blue.gui}', ${blue.cterm}], 'bold'], [['${white.gui}', ${white.cterm}], ['${split.gui}', ${split.cterm}]]]
      \ },
      \ 'replace': {
      \   'left': [[['${split.gui}', ${split.cterm}], ['${red.gui}', ${red.cterm}], 'bold'], [['${white.gui}', ${white.cterm}], ['${split.gui}', ${split.cterm}]]],
      \   'right': [[['${split.gui}', ${split.cterm}], ['${red.gui}', ${red.cterm}], 'bold'], [['${white.gui}', ${white.cterm}], ['${split.gui}', ${split.cterm}]]]
      \ },
      \ 'visual': {
      \   'left': [[['${split.gui}', ${split.cterm}], ['${purple.gui}', ${purple.cterm}], 'bold'], [['${white.gui}', ${white.cterm}], ['${split.gui}', ${split.cterm}]]],
      \   'right': [[['${split.gui}', ${split.cterm}], ['${purple.gui}', ${purple.cterm}], 'bold'], [['${white.gui}', ${white.cterm}], ['${split.gui}', ${split.cterm}]]]
      \ },
      \ 'tabline': {
      \   'left': [[['${white.gui}', ${white.cterm}], ['${split.gui}', ${split.cterm}]]],
      \   'tabsel': [[['${split.gui}', ${split.cterm}], ['${purple.gui}', ${purple.cterm}], 'bold']],
      \   'middle': [[['${brightWhite.gui}', ${brightWhite.cterm}], ['NONE', 0]]],
      \   'right': [[['${split.gui}', ${split.cterm}], ['${green.gui}', ${green.cterm}], 'bold'], [['${white.gui}', ${white.cterm}], ['${split.gui}', ${split.cterm}]]]
      \ }
      \ })
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

  mkKittyTheme = colors: ''
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
