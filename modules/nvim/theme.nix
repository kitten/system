{ pkgs, ... } @ inputs:

let
  inherit (import ../../lib/colors.nix inputs) colors mkNeovimHighlights;

  highlights = with colors; mkNeovimHighlights {
    # Highlighting Groups (descriptions and ordering from `:h hitest.vim`)
    ColorColumn.bg = cursor;
    Conceal.force = true;
    Cursor = { fg = black; bg = blue; };
    CursorIM.force = true;
    CursorColumn.bg = cursor;
    CursorLine.bg = gutter;
    Directory.fg = blue;
    ErrorMsg.fg = brightRed;
    WarningMsg.fg = yellow;
    VertSplit.fg = gutter;
    Folded = { bg = gutter; fg = muted; };
    FoldColumn.force = true;
    SignColumn.force = true;
    IncSearch = { fg = blue; reverse = true; };
    LineNr = { fg = black; bg = black; };
    CursorLineNr = { fg = muted; bg = gutter; bold = true; };
    MatchParen = { fg = blue; underline = true; };
    ModeMsg.force = true;
    MoreMsg.force = true;
    NonText.fg = element;
    Normal.fg = white;
    Question.fg = purple;
    SpecialKey.fg = element;
    Search = { fg = black; bg = yellow; };

    StatusLine = { fg = white; bg = cursor; };
    StatusLineNC.fg = muted;
    Title.fg = green;
    Visual.bg = grey;
    VisualNOS.fg = grey;
    WildMenu = { fg = black; bg = blue; };
    NormalFloat.bg = split;
    TreesitterContext.bg = gutter;

    Diff = {
      Add.bg = gutter;
      Change.force = true;
      Delete.fg = muted;
      Text = { strikethrough = true; };
    };

    Pmenu = {
      base = { bg = split; blend = 10; };
      Sel = { fg = black; bg = blue; };
      Sbar.bg = element;
      Thumb.bg = white;
    };

    Spell = {
      Bad = { fg = red; undercurl = true; };
      Cap.fg = orange;
      Local.fg = orange;
      Rare.fg = orange;
    };

    TabLine = {
      base.fg = muted;
      Fill.force = true;
      Sel.fg = white;
    };

    GitSigns = {
      Add.fg = green;
      Change.fg = brightBlue;
      Delete.fg = brightRed;
    };

    Diagnostic = {
      Warn.fg = yellow;
      Error.fg = brightRed;
      Info.fg = blue;
      Hint.fg = yellow;
      Ok.fg = green;
    };

    DiagnosticSign = {
      Warn.link = "DiagnosticWarn";
      Error.link = "DiagnosticError";
      Info.link = "DiagnosticInfo";
      Hint.link = "DiagnosticHint";
      Ok.link = "DiagnosticOk";
    };

    DiagnosticUnderline = {
      Error = { sp = brightRed; undercurl = true; };
      Warn = { sp = yellow; undercurl = true; };
      Info = { sp = blue; underdashed = true; };
      Hint = { sp = muted; underdotted = true; };
    };

    Telescope = {
      Border.fg = split;
      Matching = { fg = blue; bold = true; };
    };

    # Syntax Groups (descriptions and ordering from `:h w18`)
    Comment = { fg = muted; italic = true; };
    Constant.fg = aqua;
    String.fg = green;
    Character.fg = green;
    Number.fg = orange;
    Float.fg = orange;
    Boolean = { fg = red; };
    Identifier.fg = pink;
    Function.fg = blue;
    Statement.fg = purple;
    Conditional.fg = purple;
    Repeat.fg = purple;
    Label.fg = purple;
    Operator.fg = aqua;
    Keyword.fg = purple;
    Tag.fg = pink;
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
    SpecialChar.force = true;
    Delimiter.link = "Operator";
    Debug.force = true;
    Ignore.force = true;
    SpecialComment.fg = muted;
    Error.fg = brightRed;
    Todo.fg = purple;
    Underlined.underline = true;
    GhostText.link = "Comment";

    "@comment.todo" = { fg = purple; underline = true; };
    "@comment.note".link = "@comment.todo";
    "@markup.raw".link = "String";
    "@markup.list".link = "Operator";
    "@markup.strong".bold = true;
    "@markup.strikethrough".strikethrough = true;
    "@markup.italic".italic = true;
    "@markup.link.label".link = "SpecialComment";
    "@markup.link.url" = { fg = blue; underline = true; };
    "@string.special.url" = { fg = blue; underline = true; };
    "@punctuation.bracket".link = "Operator";
  };
in {
  my-theme = pkgs.vimUtils.buildVimPlugin {
    name = "my-theme";
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
