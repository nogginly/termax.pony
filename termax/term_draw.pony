
trait val GridChars
  """
  Define a line style for drawing a grid.
  """
  fun top_left() : String val
  fun top_right() : String val
  fun bottom_left() : String val
  fun bottom_right() : String val
  fun side() : String val
  fun bar() : String val
  fun left_join() : String val 
  fun right_join() : String val 
  fun top_join() : String val 
  fun bottom_join() : String val 
  fun mid_join() : String val 

primitive SingleSolidLine is GridChars
  """
  Single solid line style for drawing a grid.
  """
  fun top_left() : String val => "┌"
  fun top_right() : String val => "┐"
  fun bottom_left() : String val => "└"
  fun bottom_right() : String val => "┘"
  fun side() : String val => "│"
  fun bar() : String val => "─"
  fun left_join() : String val => "├"
  fun right_join() : String val => "┤"
  fun top_join() : String val => "┬"
  fun bottom_join() : String val => "┴"
  fun mid_join() : String val => "┼"

primitive SingleDashedLine is GridChars
  """
  Single dashed line style for drawing a grid.
  """
  fun top_left() : String val => "┌"
  fun top_right() : String val => "┐"
  fun bottom_left() : String val => "└"
  fun bottom_right() : String val => "┘"
  fun side() : String val => "¦"
  fun bar() : String val => "-"
  fun left_join() : String val => "├"
  fun right_join() : String val => "┤"
  fun top_join() : String val => "┬"
  fun bottom_join() : String val => "┴"
  fun mid_join() : String val => "+"

primitive DoubleSolidLine is GridChars
  """
  Double solid line style for drawing a grid.
  """
  fun top_left() : String val => "╔"
  fun top_right() : String val => "╗"
  fun bottom_left() : String val => "╚"
  fun bottom_right() : String val => "╝"
  fun side() : String val => "║"
  fun bar() : String val => "═"
  fun left_join() : String val => "╠"
  fun right_join() : String val => "╣"
  fun top_join() : String val => "╦"
  fun bottom_join() : String val => "╩"
  fun mid_join() : String val => "╬"

primitive FillPattern
  """
  Different characters that are useful as fill patterns.
  """
  fun blank() : String val => " "
  fun solid() : String val => "█"
  fun solid_top_half() : String val => "▀" 
  fun solid_bottom_half() : String val => "▄" 
  fun dither_light() : String val => "░"
  fun dither_medium() : String val => "▒"
  fun dither_dark() : String val => "▓"

trait TerminalDrawing
  """
  Defines convenient helper functions for drawing shapes in the terminal
  """

  fun hline(width: U32, fill: String val) : String val =>
    """
    Draw a horizontal line (row) using any character
    """
    Term.repeat_char(fill, width)

  fun vline(height: U32, fill: String val) : String val =>
    """
    Draw a vertical line (column) using any character
    """
    match height
    | 0 => ""
    | 1 => fill
    else
      fill + (Term.down(1) + Term.left(1) + fill).repeat_str((height - 1).usize())
    end

  fun fill_rectangle(width: U32, height: U32, fill: String val) : String val =>
    """
    Fill a rectangular area with any character
    """
    if (height == 0) or (width == 0) then
      return ""
    elseif (width == 1) and (height == 1) then
      return fill
    elseif width == 1 then
      return vline(height, fill)
    end

    let line = hline(width, fill)
    if height == 1 then
      line
    else
      let strsize = (height * (2 + 8)).usize()
      let str: String ref = String(strsize)
      str.append(line)
      let down_left: String val = Term.down(1) + Term.left(width)
      var rows = height - 1
      repeat
        str.>append(down_left)
           .>append(line)
        rows = rows - 1
      until rows == 0 end
      str.string()
    end
  
  fun frame_hline(width: U32, style: GridChars = SingleSolidLine) : String val =>
    """
    Draw a horizontal line using a line style.
    """
    hline(width, style.bar())

  fun frame_vline(height: U32, style: GridChars = SingleSolidLine) : String val =>
    """
    Draw a vertical line using a line style.
    """
    vline(height, style.side())

  fun frame(width: U32, height: U32, style: GridChars = SingleSolidLine, clear: Bool = false) : String val =>
    """
    Draw a rectangle using a line style (default is single solid line) with option to
    clear the space within the rectangle.
    """
    if (height == 0) or (width == 0) then
      return ""
    elseif (width == 1) and (height == 1) then
      return "¤"
    elseif height == 1 then
      return hline(width, style.bar())
    elseif width == 1 then
      return vline(height, style.side())
    end
    
    let strsize = (height * (2 + 8)).usize()
    let str: String ref = String(strsize)
    let down_left: String val = Term.down(1) + Term.left(width)
    let bar_filler: String val = if width <= 2 then "" else hline(width-2, style.bar()) end
    // top row
    str.>append(style.top_left())
        .>append(bar_filler)
        .>append(style.top_right())
    // middle rows
    if height > 2 then
      let in_filler = if width <= 2 then "" 
                      elseif clear then hline(width-2, FillPattern.blank()) 
                      else Term.right(width-2) end
      var rows = height-2
      let side = style.side()
      repeat
        str.>append(down_left)
            .>append(side)
            .>append(in_filler)
            .>append(side)
        rows = rows - 1
      until rows == 0 end
    end
    // bottom row
    str.>append(down_left)
        .>append(style.bottom_left())
        .>append(bar_filler)
        .>append(style.bottom_right())
    str.string()

primitive TermDraw is TerminalDrawing
  """
  Use this primitive directly to draw shapes. 
  """
