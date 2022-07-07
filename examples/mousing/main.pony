use "../../termax"

class _Listen is (TerminalNotify & TerminalTextFormatting)
  let _out: OutStream

  new iso create(env': Env) =>
    _out = env'.out
    write(
      Term.switch_to_alt_screen() + 
      Term.clear() +
      Term.mouse_enable())

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

  fun ref _show_mods(ctrl: Bool, alt: Bool, shift: Bool) =>
    if ctrl then write_at(50, 2, invert(" CTRL ")) end
    if shift then write_at(60, 2, invert(" SHIFT ")) end
    if alt then write_at(70, 2, invert(" ALT ")) end

  fun ref _show_mouse(name : String, button: MouseButton, x: U32, y: U32) =>
    write_at(0, 2, "Last event: Mouse", EraseAfter)
    write_at(20, 2, bold(name))
    match button
    | let b : KnownMouseButton =>
        write_at(30, 2, underline(b.string()))
    end
    write_at(40, 2, "X " + x.string())
    write_at(45, 2, "Y " + y.string())

  fun ref mouse_move(ctrl: Bool, alt: Bool, shift: Bool, x: U32, y: U32) =>
    _show_mouse("MOVE", UnknownMouseButton, x, y)
    _show_mods(ctrl, alt, shift)
    write(Term.cursor(x, y))

  fun ref _draw_char(button: MouseButton, ctrl: Bool, alt: Bool, shift: Bool) : String =>
    match button
    | LeftMouseButton => 
      if ctrl then "c"
      elseif alt then "a" 
      elseif shift then "s"
      else "o" end
    | RightMouseButton =>
      if ctrl then "/"
      elseif alt then "\\" 
      elseif shift then "|"
      else "-" end
    | MiddleMouseButton =>
      if ctrl then "<"
      elseif alt then ">" 
      elseif shift then "^"
      else "v" end
    else
      "."
    end

  fun ref mouse_drag(button: MouseButton, ctrl: Bool, alt: Bool, shift: Bool, x: U32, y: U32) =>
    _show_mouse("DRAG", button, x, y)
    _show_mods(ctrl, alt, shift)
    write(Term.cursor(x, y) + _draw_char(button, ctrl, alt, shift) + Term.left(1))

  fun ref mouse_press(button: MouseButton, ctrl: Bool, alt: Bool, shift: Bool, x: U32, y: U32) =>
    _show_mouse("PRESS", button, x, y)
    _show_mods(ctrl, alt, shift)
    _show_mods(ctrl, alt, shift)

  fun ref mouse_release(button: MouseButton, ctrl: Bool, alt: Bool, shift: Bool, x: U32, y: U32) =>
    _show_mouse("RELEASE", button, x, y)
    _show_mods(ctrl, alt, shift)

  fun ref mouse_wheel(direction: ScrollDirection, ctrl: Bool, alt: Bool, shift: Bool, x: U32, y: U32) =>
    _show_mouse("SCROLL " + direction.string(), UnknownMouseButton, x, y)
    _show_mods(ctrl, alt, shift)

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
    term.prompt ("Press Ctrl-C to quit. Move the mouse, press and drag, scroll/swipe, use Ctrl, Shift and Alt.")
