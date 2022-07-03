interface TerminalNotify
  """
  Receive input from an Terminal.
  """
  fun ref apply(term: Terminal ref, input: U8) =>
    None

  fun ref up(ctrl: Bool, alt: Bool, shift: Bool) =>
    None

  fun ref down(ctrl: Bool, alt: Bool, shift: Bool) =>
    None

  fun ref left(ctrl: Bool, alt: Bool, shift: Bool) =>
    None

  fun ref right(ctrl: Bool, alt: Bool, shift: Bool) =>
    None

  fun ref delete(ctrl: Bool, alt: Bool, shift: Bool) =>
    None

  fun ref insert(ctrl: Bool, alt: Bool, shift: Bool) =>
    None

  fun ref home(ctrl: Bool, alt: Bool, shift: Bool) =>
    None

  fun ref end_key(ctrl: Bool, alt: Bool, shift: Bool) =>
    None

  fun ref page_up(ctrl: Bool, alt: Bool, shift: Bool) =>
    None

  fun ref page_down(ctrl: Bool, alt: Bool, shift: Bool) =>
    None

  fun ref fn_key(i: U8, ctrl: Bool, alt: Bool, shift: Bool) =>
    None

  fun ref prompt(term: Terminal ref, value: String) =>
    None

  fun ref size(rows: U16, cols: U16) =>
    None

  fun ref closed() =>
    None

  // the new ones
  
  fun ref mouse_release(button: MouseButton, ctrl: Bool, alt: Bool, shift: Bool, x: U32, y: U32) =>
    None

  fun ref mouse_press(button: MouseButton, ctrl: Bool, alt: Bool, shift: Bool, x: U32, y: U32) =>
    None

  fun ref mouse_move(ctrl: Bool, alt: Bool, shift: Bool, x: U32, y: U32) =>
    None

  fun ref mouse_drag(button: MouseButton, ctrl: Bool, alt: Bool, shift: Bool, x: U32, y: U32) =>
    None

  fun ref mouse_wheel(direction: ScrollDirection, ctrl: Bool, alt: Bool, shift: Bool, x: U32, y: U32) =>
    None
  
