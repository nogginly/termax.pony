
trait TerminalEscapeCodes
  """
  These strings can be embedded in text when writing to a StdStream to create
  a text-based UI.
  """
  fun up(n: U32 = 0): String =>
    """
    Move the cursor up n lines. 0 is the same as 1.
    """
    if n <= 1 then
      "\e[A"
    else
      "\e[" + n.string() + "A"
    end

  fun down(n: U32 = 0): String =>
    """
    Move the cursor down n lines. 0 is the same as 1.
    """
    if n <= 1 then
      "\e[B"
    else
      "\e[" + n.string() + "B"
    end

  fun right(n: U32 = 0): String =>
    """
    Move the cursor right n columns. 0 is the same as 1.
    """
    if n <= 1 then
      "\e[C"
    else
      "\e[" + n.string() + "C"
    end

  fun left(n: U32 = 0): String =>
    """
    Move the cursor left n columns. 0 is the same as 1.
    """
    if n <= 1 then
      "\e[D"
    else
      "\e[" + n.string() + "D"
    end

  fun cursor(x: U32 = 0, y: U32 = 0): String =>
    """
    Move the cursor to line y, column x. 0 is the same as 1. This indexes from
    the top left corner of the screen.
    """
    if (x <= 1) and (y <= 1) then
      "\e[H"
    else
      "\e[" + y.string() + ";" + x.string() + "H"
    end

  fun clear(how_much: EraseDisplay = EraseAll): String =>
    """
    Clear the screen and move the cursor to the top left corner.
    """
    match how_much
    | EraseBefore => "\e[1J"
    | EraseAfter => "\e[0J"
    | EraseAll => "\e[H\e[2J" // also move cursor
    end

  fun erase(how_much : EraseLine = EraseBefore): String =>
    """
    Erases some or all of the line the cursor is on.
    """
    match how_much
    | EraseBefore => "\e[1K"
    | EraseAfter => "\e[0K"
    | EraseAll => "\e[2K"
    end

  fun reset(): String =>
    """
    Resets all colours and text styles to the default.
    """
    "\e[0m"

  fun bold(state: Bool = true): String =>
    """
    Bold text. Does nothing on Windows.
    """
    if state then "\e[1m" else "\e[22m" end

  fun underline(state: Bool = true): String =>
    """
    Underlined text. Does nothing on Windows.
    """
    if state then "\e[4m" else "\e[24m" end

  fun blink(state: Bool = true): String =>
    """
    Blinking text. Does nothing on Windows.
    """
    if state then "\e[5m" else "\e[25m" end

  fun reverse(state: Bool = true): String =>
    """
    Swap foreground and background colour.
    """
    if state then "\e[7m" else "\e[27m" end

  fun black(): String =>
    """
    Black text.
    """
    "\e[30m"

  fun red(): String =>
    """
    Red text.
    """
    "\e[31m"

  fun green(): String =>
    """
    Green text.
    """
    "\e[32m"

  fun yellow(): String =>
    """
    Yellow text.
    """
    "\e[33m"

  fun blue(): String =>
    """
    Blue text.
    """
    "\e[34m"

  fun magenta(): String =>
    """
    Magenta text.
    """
    "\e[35m"

  fun cyan(): String =>
    """
    Cyan text.
    """
    "\e[36m"

  fun grey(): String =>
    """
    Grey text.
    """
    "\e[90m"

  fun white(): String =>
    """
    White text.
    """
    "\e[97m"

  fun bright_red(): String =>
    """
    Bright red text.
    """
    "\e[91m"

  fun bright_green(): String =>
    """
    Bright green text.
    """
    "\e[92m"

  fun bright_yellow(): String =>
    """
    Bright yellow text.
    """
    "\e[93m"

  fun bright_blue(): String =>
    """
    Bright blue text.
    """
    "\e[94m"

  fun bright_magenta(): String =>
    """
    Bright magenta text.
    """
    "\e[95m"

  fun bright_cyan(): String =>
    """
    Bright cyan text.
    """
    "\e[96m"

  fun bright_grey(): String =>
    """
    Bright grey text.
    """
    "\e[37m"

  fun black_bg(): String =>
    """
    Black background.
    """
    "\e[40m"

  fun red_bg(): String =>
    """
    Red background.
    """
    "\e[41m"

  fun green_bg(): String =>
    """
    Green background.
    """
    "\e[42m"

  fun yellow_bg(): String =>
    """
    Yellow background.
    """
    "\e[43m"

  fun blue_bg(): String =>
    """
    Blue background.
    """
    "\e[44m"

  fun magenta_bg(): String =>
    """
    Magenta background.
    """
    "\e[45m"

  fun cyan_bg(): String =>
    """
    Cyan background.
    """
    "\e[46m"

  fun grey_bg(): String =>
    """
    Grey background.
    """
    "\e[100m"

  fun white_bg(): String =>
    """
    White background.
    """
    "\e[107m"

  fun bright_red_bg(): String =>
    """
    Bright red background.
    """
    "\e[101m"

  fun bright_green_bg(): String =>
    """
    Bright green background.
    """
    "\e[102m"

  fun bright_yellow_bg(): String =>
    """
    Bright yellow background.
    """
    "\e[103m"

  fun bright_blue_bg(): String =>
    """
    Bright blue background.
    """
    "\e[104m"

  fun bright_magenta_bg(): String =>
    """
    Bright magenta background.
    """
    "\e[105m"

  fun bright_cyan_bg(): String =>
    """
    Bright cyan background.
    """
    "\e[106m"

  fun bright_grey_bg(): String =>
    """
    Bright grey background.
    """
    "\e[47m"

  // the new ones

  fun cursor_save() : String =>
    """
    Save current cursor position
    """
    "\e7"

  fun cursor_restore() : String =>
    """
    Restore last saved cursor position
    """
    "\e8"

  fun cursor_hide() : String =>
    """
    Hide the terminal cursor
    """
    "\e[?25l"

  fun cursor_show() : String =>
    """
    Show the terminal cursor
    """
    "\e[?25h"

  fun switch_to_alt_screen() : String =>
    """
    Switch to the alternate screen buffer
    """
    "\e[?1049h"

  fun switch_to_normal_screen() : String =>
    """
    Switch back to the normal screen buffer
    """
    "\e[?1049l"

  fun mouse_enable() : String =>
    """
    Enable mouse input events
    """
    "\e[?1003h\e[?1015h\e[?1006h"

  fun mouse_disable() : String =>
    """
    Disable mouse input handling
    """
    "\e[?1003l\e[?1015l\e[?1006l"

  fun reset_color(): String =>
    """
    Resets foreground colour (but not the text styles)
    """
    "\e[39m"

  fun reset_color_bg(): String =>
    """
    Resets foreground colour (but not the text styles)
    """
    "\e[49m"

  fun color(fg: U8) : String =>
    """
    Select an 8-bit foreground (text) color. 
    """
    "\e[38;5;" + fg.string() + "m"

  fun color_bg(bg: U8) : String =>
    """
    Select an 8-bit background color. 
    """
    "\e[48;5;" + bg.string() + "m"

  fun faint(state: Bool = true): String => 
    """
    Lighten (faint) text. May not work on Windows.
    """
    if state then "\e[2m" else "\e[22m" end

  fun italics(state: Bool = true): String => 
    """
    Italicize text. May not work on Windows.
    """
    if state then "\e[3m" else "\e[23m" end

  fun invert(state: Bool = true): String => 
    """
    Invert foreground/background colour. May not work on Windows.
    """
    if state then "\e[7m" else "\e[27m" end 

  fun conceal(state: Bool = true): String => 
    """
    Conceal (hide) the text. May not work on Windows.
    """
    if state then "\e[8m" else "\e[28m" end

  fun strikeout(state: Bool = true): String => 
    """
    Strike through text. May not work on Windows.
    """
    if state then "\e[9m" else "\e[29m" end

primitive Term is TerminalEscapeCodes
  """
  These strings can be embedded in text when writing to a StdStream to create
  a text-based UI.
  """
