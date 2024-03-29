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
    Search = { fg = blue; reverse = true; };
    LineNr = { fg = black; bg = black; };
    CursorLineNr = { fg = muted; bg = gutter; bold = true; };
    MatchParen = { fg = blue; underline = true; };
    ModeMsg.force = true;
    MoreMsg.force = true;
    NonText.fg = grey;
    Normal.fg = white;
    Question.fg = purple;
    SpecialKey.fg = grey;

    StatusLine = { fg = white; bg = cursor; };
    StatusLineNC.fg = muted;
    Title.fg = green;
    Visual.bg = grey;
    VisualNOS.fg = grey;
    WildMenu = { fg = black; bg = blue; };
    NormalFloat.bg = element;
    TreesitterContext.bg = gutter;

    Diff = {
      Add.bg = gutter;
      Change.force = true;
      Delete.fg = muted;
      Text = { strikethrough = true; };
    };

    Pmenu = {
      base = { bg = gutter; blend = 5; };
      Sel = { fg = black; bg = blue; };
      Sbar.force = true;
      Thumb.bg = cursor;
    };

    Spell = {
      Bad = { sp = brightRed; undercurl = true; };
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
      Change.fg = blue;
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
    Constant.fg = pink;
    String.fg = green;
    Character.fg = green;
    Number.fg = orange;
    Float.fg = orange;
    Identifier.fg = white;
    Function.fg = blue;
    Statement.fg = purple;
    Conditional.fg = red;
    Repeat.fg = purple;
    Label.fg = purple;
    Operator.fg = pink;
    Keyword.fg = purple;
    Tag.fg = pink;
    Exception.fg = brightRed;
    PreProc.fg = yellow;
    Include.fg = brightBlue;
    Define.fg = purple;
    Macro.fg = purple;
    PreCondit.fg = yellow;
    Type.fg = aqua;
    StorageClass.fg = yellow;
    Structure.fg = yellow;
    Typedef.fg = yellow;
    Special.fg = orange;
    SpecialChar.fg = brightGreen;
    Delimiter.fg = cyan;
    Debug.force = true;
    Ignore.force = true;
    SpecialComment.fg = muted;
    Error.fg = brightRed;
    Todo.fg = purple;
    GhostText.fg = grey;
    Underlined.underline = true;

    Boolean.link = "Constant";

    # Treesitter classes
    "@constructor".link = "Structure";
    "@comment.todo" = { fg = purple; underline = true; };
    "@comment.note".link = "@comment.todo";
    "@markup.raw".link = "@string";
    "@markup.list".link = "@operator";
    "@markup.strong".bold = true;
    "@markup.strikethrough".strikethrough = true;
    "@markup.italic".italic = true;
    "@markup.link.label".link = "SpecialComment";
    "@markup.link.url" = { fg = brightBlue; underline = true; };
    "@markup.heading" = { fg = cyan; bold = true; };
    "@string.special.url" = { fg = brightBlue; underline = true; };
    "@punctuation.bracket".link = "@operator";
    "@punctuation.delimiter".link = "Delimiter";
    "@punctuation.special".link = "SpecialChar";
    "@keyword.exception".link = "@conditional";
    "@keyword.return".link = "@conditional";
    "@keyword.conditional".link = "@conditional";
    "@keyword.repeat".link = "@conditional";
    "@keyword.operator".link = "@operator";
    "@keyword.import".link = "@include";
    "@type.builtin".link = "@constant";

    # LSP classes
    "@lsp.type.typeParameter".link = "@lsp.type.type";
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
