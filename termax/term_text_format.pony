
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

primitive TermFmt is TerminalTextFormatting
  """
  Use this primitive directly to format strings. 
  """
