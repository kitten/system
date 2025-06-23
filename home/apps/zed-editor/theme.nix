{ pkgs, ... } @ inputs:

let
  inherit (import ../../../lib/colors.nix inputs) colors mkZedStyles;

  raw = let
    element = colors.element.gui;
    cursor = colors.cursor.gui;
    gutter = colors.gutter.gui;
    split = colors.split.gui;

    black = colors.black.gui;
    grey = colors.grey.gui;
    red = colors.red.gui;
    brightRed = colors.brightRed.gui;
    green = colors.green.gui;
    brightGreen = colors.brightGreen.gui;
    yellow = colors.yellow.gui;
    orange = colors.orange.gui;
    blue = colors.blue.gui;
    brightBlue = colors.brightBlue.gui;
    pink = colors.pink.gui;
    magenta = colors.magenta.gui;
    aqua = colors.aqua.gui;
    cyan = colors.cyan.gui;
    white = colors.white.gui;
    muted = colors.muted.gui;

    attribute = magenta;
    keyword = magenta;
    define = magenta;
    macro = magenta;
    label = magenta;

    property = pink;
    constant = pink;
    operator = pink;
    tag = pink;

    url = brightBlue;
    include = brightBlue;

    delimiter = cyan;
    typedef = yellow;
    type = aqua;
    conditional = red;
    special = orange;
    string = green;
    specialChar = brightGreen;
    number = orange;
    function = blue;
    identifier = white;
    structure = yellow;
  in {
    players = [
      {
        cursor = white;
        selection = cursor;
      }
    ];

    syntax = {
      attribute.color = attribute;
      constant.color = constant;
      keyword.color = keyword;
      "keyword.type".color = structure;
      "constant.builtin".color = special;
      "constant.macro".color = define;
      string.color = green;
      "string.escape".color = specialChar;
      "string.special".color = specialChar;
      number.color = number;
      "number.float".color = number;
      function.color = function;
      "function.builtin".color = special;
      "function.macro".color = macro;
      "function.method".color = function;
      "function.parameter".color = function;
      variable.color = identifier;
      "variable.parameter".color = identifier;
      "variable.parameter.builtin".color = special;
      "variable.member".color = property;
      "variable.builtin".color = special;
      "attribute.builtin".color = special;
      label.color = label;
      operator.color = operator;
      conditional.color = conditional;
      include.color = include;
      boolean.color = conditional;
      type.color = type;
      "type.definition".color = typedef;
      "type.builtin".color = special;
      module.color = identifier;
      tag.color = tag;
      "tag.builtin".color = special;
      constructor.color = structure;
      "markup.raw".color = string;
      "markup.list".color = operator;
      "markup.link.label".color = delimiter;
      "string.special.url".color = url;
      "punctuation.bracket".color = operator;
      "punctuation.delimiter".color = delimiter;
      "punctuation.special".color = specialChar;
      "keyword.exception".color = conditional;
      "keyword.return".color = conditional;
      "keyword.conditional".color = conditional;
      "keyword.repeat".color = conditional;
      "keyword.operator".color = operator;
      "keyword.import".color = include;
      "property".color = property;

      comment = {
        color = muted;
        font_style = "italic";
      };

      "comment.todo".color = brightBlue;
      "comment.error".color = brightRed;
      "comment.note".color = magenta;
    };
  };

  style = with colors; mkZedStyles {
    background = black;
    drop_target.background = element;

    editor = {
      background = black;
      foreground = white;
      invisible = grey;
      gutter.background = black;
      active_line.background = gutter;
      active_line_number = muted;
      line_number = grey;
      document_highlight = {
        read_background = element;
        write_background = element;
      };
    };

    subheader.background = black;
    status_bar.background = black;
    panel.background = black;
    elevated_surface.background = element;
    tab_bar.background = black;
    title_bar.background = black;

    toolbar = {
      background = black;
    };

    tab = {
      active_background = black;
      inactive_background = gutter;
    };

    search.match_background = blue;

    text = {
      base = white;
      muted = muted;
      accent = blue;
      disabled = grey;
      placeholder = cursor;
    };

    border = {
      base = split;
      variant = gutter;
    };

    scrollbar = {
      track.background = black;
      thumb.background = muted;
    };

    error = red;
    hint = brightBlue;
    info = blue;
    predictive = grey;
    renamed = yellow;
    success = green;
    unreachable = brightRed;
    warning = orange;

    conflict = red;
    created = green;
    deleted = brightRed;
    hidden = muted;
    ignored = grey;
    modified = blue;

    element = {
      background = element;
      hover = cursor;
      selected = cursor;
    };

    terminal = {
      background = black;
      bright_foreground = grey;
      dim_foreground = gutter;
      ansi = {
        black = black;
        bright_black = grey;
        red = red;
        bright_red = brightRed;
        green = green;
        bright_green = brightGreen;
        yellow = yellow;
        bright_yellow = orange;
        blue = blue;
        bright_blue = brightBlue;
        magenta = pink;
        bright_magenta = magenta;
        cyan = aqua;
        bright_cyan = cyan;
        white = white;
        bright_white = muted;
      };
    };
  };
in {
  system-theme = {
    "$schema" = "https://zed.dev/schema/themes/v0.2.0.json";
    name = "System";
    author = "@kitten";
    themes = let
      theme = {
        name = "System Dark";
        appearance = "dark";
        style = style // raw;
      };
    in [ theme ];
  };
}

