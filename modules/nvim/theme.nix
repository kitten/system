{ pkgs, ... } @ inputs:

let
  inherit (import ../../lib/colors.nix inputs) colors mkNeovimHighlights;

  highlights = with colors; mkNeovimHighlights {
    # Syntax Groups (descriptions and ordering from `:h w18`)
    Comment = { fg = brightWhite; italic = true; };
    Constant.fg = cyan;
    String.fg = green;
    Character.fg = green;
    Number.fg = brightYellow;
    Float.fg = brightYellow;
    Boolean = { fg = red; };
    Identifier.fg = red;
    Function.fg = blue;
    Statement.fg = purple;
    Conditional.fg = purple;
    Repeat.fg = purple;
    Label.fg = purple;
    Operator.fg = cyan;
    Keyword.fg = red;
    Exception.fg = purple;
    PreProc.fg = yellow;
    Include.fg = blue;
    Define.fg = purple;
    Macro.fg = purple;
    PreCondit.fg = yellow;
    Type.fg = yellow;
    StorageClass.fg = yellow;
    Structure.fg = yellow;
    Typedef.fg = yellow;
    Special.fg = blue;
    SpecialChar.default = true;
    Tag.default = true;
    Delimiter.default = true;
    Debug.default = true;
    Ignore.default = true;
    SpecialComment.fg = brightWhite;
    Error.fg = brightRed;
    Todo.fg = purple;
    Underlined.underline = true;

    # Highlighting Groups (descriptions and ordering from `:h hitest.vim`)
    ColorColumn.bg = cursor;
    Conceal.default = true;
    Cursor = { fg = black; bg = blue; };
    CursorIM.default = true;
    CursorColumn.bg = cursor;
    CursorLine.bg = gutter;
    Directory.fg = blue;
    ErrorMsg.fg = brightRed;
    WarningMsg.fg = yellow;
    VertSplit.fg = gutter;
    Folded = { bg = gutter; fg = brightWhite; };
    FoldColumn.default = true;
    SignColumn.default = true;
    IncSearch = { fg = blue; reverse = true; };
    LineNr = { fg = black; bg = black; };
    CursorLineNr = { fg = brightWhite; bg = gutter; bold = true; };
    MatchParen = { fg = blue; underline = true; };
    ModeMsg.default = true;
    MoreMsg.default = true;
    NonText.fg = element;
    Normal.fg = darkWhite;
    Question.fg = purple;
    SpecialKey.fg = element;
    Search = { fg = black; bg = yellow; };

    StatusLine = { fg = white; bg = cursor; };
    StatusLineNC.fg = brightWhite;
    Title.fg = green;
    Visual.bg = grey;
    VisualNOS.fg = grey;
    WildMenu = { fg = black; bg = blue; };
    NormalFloat.bg = split;
    TreesitterContext.bg = gutter;

    Diff = {
      Add.bg = gutter;
      Change.default = true;
      Delete.fg = brightWhite;
      Text = { strikethrough = true; };
    };

    Pmenu = {
      base.bg = grey;
      Sel = { fg = black; bg = blue; };
      Sbar.bg = element;
      Thumb.bg = white;
    };

    Spell = {
      Bad = { fg = red; underline = true; };
      Cap.fg = brightYellow;
      Local.fg = brightYellow;
      Rare.fg = brightYellow;
    };

    TabLine = {
      base.fg = brightWhite;
      Fill.default = true;
      Sel.fg = white;
    };

    GitSigns = {
      Add.fg = green;
      Change.fg = brightBlue;
      Delete.fg = brightRed;
    };

    DiagnosticSign = {
      Warn.fg = yellow;
      Error.fg = brightRed;
      Information.fg = blue;
      Hint.fg = yellow;
    };

    Telescope = {
      Border.fg = split;
      Matching = { fg = blue; bold = true; };
    };
  };
in {
  my-theme = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "my-theme";
    version = "2020-10-23";
    src = pkgs.writeTextFile {
      name = "theme.vim";
      destination = "/colors/theme.lua";
      text = ''
        vim.cmd('highlight clear')
        vim.cmd('syntax reset')
        ${highlights}
      '';
    };
  };
}
