{ stdenv, writeText }:

let
  basic = builtins.readFile ./basic.vim;
  theme = builtins.readFile ./theme.vim;
  plugins = builtins.readFile ./plugins.vim;
  keymap = builtins.readFile ./keymap.vim;
in

''
  ${basic}
  ${theme}
  ${plugins}
  ${keymap}
''

