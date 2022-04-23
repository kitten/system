let
  inherit (import ../modules/color-utils.nix) mkLuaSyntax mkVimSyntax mkVimHardlineColors mkColor mkHighlight;
in rec {
  colors = {
    gutter = (mkColor "#16171d" "232" "15"); # gutter fg grey
    cursor = (mkColor "#2C323C" "236" "8"); # cursor grey
    element = (mkColor "#404449" "238" "15"); # special grey
    split = (mkColor "#282c34" "59" "15");

    black = (mkColor "#13131a" "235" "0");
    grey = (mkColor "#3E4452" "237" "15");

    red = (mkColor "#ED95A8" "204" "1");
    brightRed = (mkColor "#EF5350" "196" "9");

    green = (mkColor "#C3E88D" "114" "2");
    brightGreen = (mkColor "#C3E88D" "114" "2");

    yellow = (mkColor "#FFCB6B" "180" "3");
    brightYellow = (mkColor "#F78C6C" "173" "11"); # dark yellow

    blue = (mkColor "#82B1FF" "39" "4");
    brightBlue = (mkColor "#939EDE" "39" "4"); # blue purple

    purple = (mkColor "#C792EA" "170" "5");
    brightPurple = (mkColor "#FF45AE" "170" "5");

    cyan = (mkColor "#89DDFF" "38" "6");
    brightCyan = (mkColor "#20D6E3" "38" "6");

    white = (mkColor "#ECEFF1" "145" "7");
    brightWhite = (mkColor "#697098" "59" "15"); # comment grey
    darkWhite = (mkColor "#F8F8F2" "59" "15");
  };

  vim-hardline = mkVimHardlineColors colors;
  lua = mkLuaSyntax colors;

  vim = with colors; mkVimSyntax "theme" {
    # Syntax Groups (descriptions and ordering from `:h w18`)
    Comment = { fg = brightWhite; style = "italic"; };
    Constant = { fg = cyan; };
    String = { fg = green; };
    Character = { fg = green; };
    Number = { fg = brightYellow; };
    Boolean = { fg = red; };
    Float = { fg = brightYellow; };
    Identifier = { fg = red; };
    Function = { fg = blue; };
    Statement = { fg = purple; };
    Conditional = { fg = purple; };
    Repeat = { fg = purple; };
    Label = { fg = purple; };
    Operator = { fg = cyan; };
    Keyword = { fg = red; };
    Exception = { fg = purple; };
    PreProc = { fg = yellow; };
    Include = { fg = blue; };
    Define = { fg = purple; };
    Macro = { fg = purple; };
    PreCondit = { fg = yellow; };
    Type = { fg = yellow; };
    StorageClass = { fg = yellow; };
    Structure = { fg = yellow; };
    Typedef = { fg = yellow; };
    Special = { fg = blue; };
    SpecialChar = mkHighlight {};
    Tag = mkHighlight {};
    Delimiter = mkHighlight {};
    Debug = mkHighlight {};
    Ignore = mkHighlight {};
    SpecialComment = { fg = brightWhite; };
    Underlined = mkHighlight { style = "underline"; };
    Error = { fg = brightRed; };
    Todo = { fg = purple; };

    # Highlighting Groups (descriptions and ordering from `:h hitest.vim`)
    ColorColumn = { bg = cursor; };
    Conceal = mkHighlight {};
    Cursor = { fg = black; bg=blue; };
    CursorIM = mkHighlight {};
    CursorColumn = { bg = cursor; };
    CursorLine = { bg = gutter; };
    Directory = { fg = blue; };

    Diff = {
      Add = { bg = gutter; };
      Change = mkHighlight {};
      Delete = { fg = brightWhite; };
      Text = { style = "strikethrough"; };
    };

    Pmenu = {
      base = { bg = grey; };
      Sel = { fg = black; bg = blue; };
      Sbar = { bg = element; };
      Thumb = { bg = white; };
    };

    ErrorMsg = { fg = brightRed; };
    WarningMsg = { fg = yellow; };
    VertSplit = { fg = gutter; };
    Folded = { bg = gutter; fg = brightWhite; };
    FoldColumn = mkHighlight {};
    SignColumn = mkHighlight {};
    IncSearch = { fg = blue; style = "reverse"; };
    LineNr = { fg = black; bg = black; };
    CursorLineNr = { fg = brightWhite; bg = gutter; style = "bold"; };
    MatchParen = { fg = blue; style = "underline"; };
    ModeMsg = mkHighlight {};
    MoreMsg = mkHighlight {};
    NonText = { fg = element; };
    Normal = { fg = darkWhite; };
    Question = { fg = purple; };
    Search = { fg = black; bg = yellow; };
    SpecialKey = { fg = element; };

    Spell = {
      Bad = { fg = red; style = "underline"; };
      Cap = { fg = brightYellow; };
      Local = { fg = brightYellow; };
      Rare = { fg = brightYellow; };
    };

    TabLine = {
      base = { fg = brightWhite; };
      Fill = mkHighlight {};
      Sel = { fg = white; };
    };

    StatusLine = { fg = white; bg = cursor; };
    StatusLineNC = { fg = brightWhite; };
    Title = { fg = green; };
    Visual = { bg = grey; };
    VisualNOS = { fg = grey; };
    WildMenu = { fg = black; bg = blue; };
    NormalFloat = { bg = split; };
    TreesitterContext = { bg = gutter; };

    dockerfile.Keyword = { fg = purple; };

    sh = {
      Set = { fg = cyan; };
      SetOption = { fg = white; };
      Statement = { fg = cyan; };
      FunctionKey = { fg = purple; };
    };

    css = {
      AttrComma = { fg = purple; };
      AttributeSelector = { fg = green; };
      Braces = { fg = white; };
      ClassName = { fg = brightYellow; };
      ClassNameDot = { fg = brightYellow; };
      Definition = { fg = purple; };
      FontAttr = { fg = brightYellow; };
      FontDescriptor = { fg = purple; };
      FunctionName = { fg = blue; };
      Identifier = { fg = blue; };
      Important = { fg = purple; };
      Include = { fg = white; };
      IncludeKeyword = { fg = purple; };
      MediaType = { fg = brightYellow; };
      Prop = { fg = purple; };
      PseudoClassId = { fg = brightYellow; };
      SelectorOp = { fg = purple; };
      SelectorOp2 = { fg = purple; };
      TagName = { fg = red; };
      Color = { fg = brightYellow; };
      CommonAttr = { fg = blue; };
      UnitDecorators = { fg = yellow; };
    };

    go.Declaration = { fg = purple; };

    html = {
      Title = { fg = white; };
      Arg = { fg = yellow; };
      EndTag = { fg = cyan; };
      Link = { fg = purple; };
      SpecialChar = { fg = brightYellow; };
      SpecialTagName = { fg = red; };
      Tag = { fg = cyan; };
      TagName = { fg = red; };
      H1 = { fg = blue; };
      H2 = { fg = blue; };
      H3 = { fg = blue; };
      H4 = { fg = blue; };
      H5 = { fg = blue; };
      H6 = { fg = blue; };
    };

    javaScript = {
      Braces = { fg = white; };
      Function = { fg = purple; };
      Identifier = { fg = purple; };
      Null = { fg = brightYellow; };
      Number = { fg = brightYellow; };
      Require = { fg = cyan; };
      Reserved = { fg = purple; };
    };

    # For: https://github.com/pangloss/vim-javascript
    js = {
      ArrowFunction = { fg = purple; };
      ClassKeyword = { fg = purple; };
      ClassDefinition = { fg = yellow; };
      ClassMethodType = { fg = purple; };
      ClassFuncName = { fg = blue; };
      DestructuringBlock = { fg = blue; };
      DocParam = { fg = blue; };
      DocTags = { fg = purple; };
      Export = { fg = purple; };
      ExportDefault = { fg = red; };
      ExtendsKeyword = { fg = purple; };
      Conditional = { fg = purple; };
      Operator = { fg = purple; };
      From = { fg = purple; };
      FuncArgs = { fg = blue; };
      FuncCall = { fg = blue; };
      ObjectProp = { fg = cyan; };
      Function = { fg = purple; };
      Generator = { fg = yellow; };
      GlobalObjects = { fg = yellow; };
      Import = { fg = purple; };
      ModuleAs = { fg = purple; };
      ModuleWords = { fg = purple; };
      ModuleKeyword = { fg = blue; };
      Modules = { fg = purple; };
      Null = { fg = brightYellow; };
      StorageClass = { fg = purple; };
      Super = { fg = red; };
      TemplateBraces = { fg = brightRed; };
      TemplateVar = { fg = green; };
      This = { fg = red; };
      Undefined = { fg = brightYellow; };
    };

    # For: https://github.com/othree/yajs.vim
    javascript = {
      ArrowFunc = { fg = purple; };
      ClassExtends = { fg = purple; };
      ClassKeyword = { fg = purple; };
      DocNotation = { fg = purple; };
      DocParamName = { fg = blue; };
      DocTags = { fg = purple; };
      EndColons = { fg = white; };
      Export = { fg = purple; };
      FuncArg = { fg = white; };
      FuncKeyword = { fg = purple; };
      Identifier = { fg = red; };
      Import = { fg = purple; };
      MethodName = { fg = white; };
      ObjectLabel = { fg = white; };
      OpSymbol = { fg = cyan; };
      OpSymbols = { fg = cyan; };
      PropertyName = { fg = green; };
      TemplateSB = { fg = brightRed; };
      Variable = { fg = purple; };
    };

    typescript = {
      Identifier = { fg = red; };
      Reserved = { fg = purple; };
      EndColons = { fg = white; };
      Braces = { fg = white; };
    };

    json = {
      CommentError = { fg = white; };
      Keyword = { fg = blue; };
      Boolean = { fg = red; };
      Number = { fg = brightYellow; };
      Quote = { fg = white; };
      String = { fg = green; };
      MissingCommaError = { fg = brightRed; style = "reverse"; };
      NoQuotesError = { fg = brightRed; style = "reverse"; };
      NumError = { fg = brightRed; style = "reverse"; };
      StringSQError = { fg = brightRed; style = "reverse"; };
      SemicolonError = { fg = brightRed; style = "reverse"; };
    };

    markdown = {
      Code = { fg = green; };
      LinkReference = { fg = brightWhite; };
      JekyllFrontMatter = { fg = brightWhite; };
      CodeBlock = { fg = green; };
      CodeDelimiter = { fg = green; };
      HeadingDelimiter = { fg = red; };
      Rule = { fg = brightWhite; };
      HeadingRule = { fg = brightWhite; };
      Delimiter = { fg = cyan; };
      Id = { fg = purple; };
      Blockquote = { fg = brightWhite; };
      Italic = { fg = purple; style = "italic"; };
      Bold = { fg = purple; style = "bold"; };
      OrderedListMarker = { fg = red; };
      IdDeclaration = { fg = blue; };
      LinkDelimiter = { fg = white; };
    };

    mkd = {
      Italic = { fg = purple; style = "italic"; };
      Bold = { fg = purple; style = "bold"; };
      InlineURL = { fg = red; };
      ListItem = { fg = yellow; };
      Link = { fg = white; };
      URL = { fg = red; };
    };

    xml = {
      Attrib = { fg = yellow; };
      EndTag = { fg = red; };
      Tag = { fg = red; };
      TagName = { fg = red; };
    };

    php = {
      Include = { fg = purple; };
      Class = { fg = yellow; };
      Classes = { fg = yellow; };
      Function = { fg = blue; };
      Type = { fg = purple; };
      Keyword = { fg = purple; };
      VarSelector = { fg = purple; };
      Identifier = { fg = white; };
      Method = { fg = blue; };
      Boolean = { fg = blue; };
      Parent = { fg = white; };
      Operator = { fg = purple; };
      Region = { fg = purple; };
      UseNamespaceSeparator = { fg = white; };
      ClassNamespaceSeparator = { fg = white; };
      DocTags = { fg = purple; style="italic"; };
      DocParam = { fg = purple; style="italic"; };
    };

    debug = {
      Breakpoint = { fg = brightBlue; };
      PC = { bg = brightBlue; fg = black; };
    };

    gitcommit = {
      Comment = { fg = brightWhite; };
      Untracked = { fg = brightWhite; };
      Discarded = { fg = brightWhite; };
      Selected = { fg = brightWhite; };
      Unmerged = { fg = green; };
      OnBranch = mkHighlight {};
      Branch = { fg = purple; };
      NoBranch = { fg = purple; };
      DiscardedType = { fg = red; };
      SelectedType = { fg = green; };
      Header = mkHighlight {};
      UntrackedFile = { fg = cyan; };
      DiscardedFile = { fg = red; };
      SelectedFile = { fg = green; };
      UntrackedArrow = { fg = cyan; };
      DiscardedArrow = { fg = red; };
      SelectedArrow = { fg = green; };
      UnmergedFile = { fg = yellow; };
      File = mkHighlight {};
      Summary = { fg = white; };
      Overflow = { fg = red; };
    };

    terminal = {
      background = { fg = black; };
      foreground = { fg = white; };
      black = { fg = black; };
      red = { fg = red; };
      green = { fg = green; };
      yellow = { fg = yellow; };
      blue = { fg = blue; };
      purple = { fg = purple; };
      cyan = { fg = cyan; };
      white = { fg = white; };
      grey = { fg = grey; };
      brightRed = { fg = brightRed; };
      brightGreen = { fg = brightGreen; };
      brightYellow = { fg = brightYellow; };
      brightBlue = { fg = brightBlue; };
      brightPurple = { fg = brightPurple; };
      brightCyan = { fg = brightCyan; };
      brightWhite = { fg = brightWhite; };
    };

    GitSigns = {
      Add = { fg = green; };
      Change = { fg = brightBlue; };
      Delete = { fg = brightRed; };
    };

    Signify = {
      Add = { fg = green; };
      Change = { fg = brightBlue; };
      Delete = { fg = brightRed; };
    };

    GitGutter = {
      Add = { fg = green; };
      Change = { fg = brightBlue; };
      Delete = { fg = brightRed; };
    };

    Neomake = {
      WarningSign = { fg = yellow; };
      ErrorSign = { fg = brightRed; };
      InfoSign = { fg = blue; };
    };

    DiagnosticSign = {
      Warn = { fg = yellow; };
      Error = { fg = brightRed; };
      Information = { fg = blue; };
      Hint = { fg = yellow; };
    };

    Telescope = {
      Border = { fg = split; };
      Matching = { fg = blue; style = "bold"; };
    };

    TS.Definition = { fg = blue; bg = brightWhite; };
    EasyMotion.IncSearch = { fg = blue; style = "bold"; };
  };
}
