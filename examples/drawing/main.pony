use "../../termax"

class _Listen is (TerminalNotify & TerminalTextFormatting)
  let _out: OutStream

  new iso create(env': Env) =>
    _out = env'.out
    write(
      Term.switch_to_alt_screen() +
      Term.clear() +
      Term.mouse_enable())

    draw_frame_at(2, 3, 13, 3, Term.white(), Term.red_bg() where clear=true)
    fill_rectangle_at(15, 4, 1, 2, Term.grey() where fill=FillPattern.solid())
    fill_rectangle_at(3, 6, 13, 1, Term.grey() where fill=FillPattern.solid_top_half())

    draw_frame_at(18, 3, 21, 2, Term.white(), Term.magenta_bg())
    draw_frame_at(5, 8, 14, 6, Term.white(), Term.blue_bg() where style=DoubleSolidLine)
    fill_rectangle_at(22, 8, 11, 7, Term.yellow() where fill="+")

    draw_hline_at(22, 17, 10, Term.green(), Term.black_bg())
    draw_hline_at(22, 18, 10, Term.green(), Term.black_bg() where style=SingleDashedLine)
    draw_hline_at(22, 19, 10, Term.green(), Term.black_bg() where style=DoubleSolidLine)

    draw_vline_at(34, 8, 10, Term.magenta(), Term.black_bg())
    draw_vline_at(35, 8, 10, Term.magenta(), Term.black_bg() where style=SingleDashedLine)
    draw_vline_at(36, 8, 10, Term.magenta(), Term.black_bg() where style=DoubleSolidLine)

    draw_frame_at(38, 6, 21, 4, Term.white(), Term.blue_bg() where style=SingleDashedLine)

  fun ref _setup_draw(x: U32, y: U32, color: String, bgcolor: (String | None) = None) =>
    """
    Save cursor position, move cursor and set colors
    """
    let str: String val = Term.cursor_save() + Term.cursor(x, y) + color
    write(match bgcolor
          | None => str
          | let s: String => str + s
          end)

  fun ref _restore_after_draw() =>
    """
    Reset colours and restore saved cursor position
    """
    write(Term.reset() + Term.cursor_restore())

  fun ref draw_hline_at(x: U32, y: U32, width: U32,
                                color: String, bgcolor: (String|None) = None,
                                style : GridChars = SingleSolidLine) =>
    """
    Draw horizontal line at specified location with color and style, restoring cursor and formatting when done
    """
    _setup_draw(x, y, color, bgcolor)
    write(TermDraw.frame_hline(width where style = style))
    _restore_after_draw()

  fun ref draw_vline_at(x: U32, y: U32, height: U32,
                                color: String, bgcolor: (String|None) = None,
                                style : GridChars = SingleSolidLine) =>
    """
    Draw vertical line at specified location with color and style, restoring cursor and formatting when done
    """
    _setup_draw(x, y, color, bgcolor)
    write(TermDraw.frame_vline(height where style = style))
    _restore_after_draw()

  fun ref fill_rectangle_at(x: U32, y: U32, width: U32, height: U32,
                            color: String, bgcolor: (String|None) = None,
                            fill: String=FillPattern.blank()) =>
    """
    Draw filled rectangle at specified location with color and style, restoring cursor and formatting when done
    """
    _setup_draw(x, y, color, bgcolor)
    write(TermDraw.fill_rectangle(width, height where fill = fill))
    _restore_after_draw()

  fun ref draw_frame_at(x: U32, y: U32, width: U32, height: U32,
                            color: String, bgcolor: (String|None) = None,
                            clear: Bool = false,
                            style : GridChars = SingleSolidLine) =>
    """
    Draw frame at specified location with color and style, restoring cursor and formatting when done
    """
    _setup_draw(x, y, color, bgcolor)
    write(TermDraw.frame(width, height where clear = clear, style = style))
    _restore_after_draw()

  fun ref write(text : String) =>
    """
    Write some text at cursor position
    """
    _out.write(text)

  fun ref write_at(x: U32, y: U32, text : String, erase: (None|EraseLine) = None) =>
    """
    Write some text at the specific cursor position, and optionally erase some or all of
    the line at the location before writing the text.
    """
    match erase
    | let e : EraseLine =>
      write(Term.cursor_save() + Term.cursor(x, y) + Term.erase(e) + text + Term.cursor_restore())
    else
      write(Term.cursor_save() + Term.cursor(x, y) + text + Term.cursor_restore())
    end

  fun ref prompt(term: Terminal ref, value: String val) =>
    """
    Write prompt at row 1, col 1 after cleaning line
    """
    write_at(1, 1, value, EraseAfter)

  fun ref apply(term: Terminal ref, input: U8 val) =>
    """
    Exit when user presses Ctrl-C
    """
    match input
    | Key.ctrl_C() => term.dispose()
    end

  fun ref closed() =>
    write(
      Term.mouse_disable() +
      Term.switch_to_normal_screen())
    write("Caught ^C - disabled mouse and switched to normal screen.\n")

actor Main
  new create(env: Env) =>
    let term = EasyTerminal(env, _Listen(env))
    term.prompt ("Press Ctrl-C to quit.")
