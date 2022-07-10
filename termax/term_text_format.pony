
trait TerminalTextFormatting
  """
  Defines convenient helper functions for visually formatting text/string-able content.
  """

  fun hide(value: Stringable val) : String => 
    """ 
    Return the value as an escape-styled "concealed" string ready for the terminal.
    """
    conceal(value)

  fun conceal(value: Stringable val) : String =>
    """
    Return the value as an escape-styled "concealed" string ready for the terminal.
    """
    Term.conceal() +  value.string() + Term.conceal(false)

  fun bold(value: Stringable val) : String =>
    """
    Return the value as an escape-styled "bold" string ready for the terminal.
    """
    Term.bold() +  value.string() + Term.bold(false)

  fun faint(value: Stringable val) : String =>
    """
    Return the value as an escape-styled "faint" (dim) string ready for the terminal.
    """
    Term.faint() +  value.string() + Term.faint(false)

  fun invert(value: Stringable val) : String =>
    """
    Return the value as an escape-styled string with foreground and background color inverted and ready for the terminal.
    """
    Term.invert() +  value.string() + Term.invert(false)

  fun italics(value: Stringable val) : String =>
    """
    Return the value as an escape-styled "italicized" string ready for the terminal.
    """
    Term.italics() +  value.string() + Term.italics(false)

  fun underline(value: Stringable val) : String =>
    """
    Return the value as an escape-styled "underlined" string ready for the terminal.
    """
    Term.underline() +  value.string() + Term.underline(false)

  fun strikeout(value: Stringable val) : String =>
    """
    Return the value as an escape-styled "struck out" string ready for the terminal.
    """
    Term.strikeout() +  value.string() + Term.strikeout(false)

  fun color(value: Stringable val, fg: U8, bg: (None|U8) = None) : String =>
    """
    Return the value escaped by 8-bit colour codes for foreground and 
    (optional) background colours.
    """
    match bg
    | let bgcolor : U8 => 
        Term.color(bgcolor) + Term.color(fg) + value.string() + 
        Term.reset_color() + Term.reset_color_bg()
    else
        Term.color(fg) + value.string() + Term.reset_color()
    end

  fun color_with(value: Stringable val, fg: String, bg: (None|String) = None) : String =>
    """
    Return the value surrounded by supplied escape codes for foreground and 
    (optional) background colours.
    """
    match bg
    | let bgcode : String => 
        bgcode + fg + value.string() + Term.reset_color() + Term.reset_color_bg()
    else
        fg + value.string() + Term.reset_color()
    end

primitive TermText is TerminalTextFormatting
  """
  Use this primitive directly to format strings. 
  """
