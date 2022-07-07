use "time"
use "signals"

use @ioctl[I32](fx: I32, cmd: ULong, ...) if posix

struct _TermSize
  var row: U16 = 0
  var col: U16 = 0
  var xpixel: U16 = 0
  var ypixel: U16 = 0

primitive _EscapeNone
primitive _EscapeStart
primitive _EscapeSS3
primitive _EscapeCSI
primitive _EscapeMod
primitive _EscapeMouseStart
primitive _EscapeMouseX
primitive _EscapeMouseY

type _EscapeState is
  ( _EscapeNone
  | _EscapeStart
  | _EscapeSS3
  | _EscapeCSI
  | _EscapeMod
  | _EscapeMouseStart
  | _EscapeMouseX
  | _EscapeMouseY
  )

class _TermResizeNotify is SignalNotify
  let _term: Terminal tag

  new create(term: Terminal tag) =>
    _term = term

  fun apply(times: U32): Bool =>
    _term.size()
    true

class _TermSigKeyNotify is SignalNotify
  let _term: Terminal tag
  let _input: U8 val

  new create(term: Terminal tag, input: U8 val) =>
    _term = term
    _input = input

  fun apply(times: U32): Bool =>
    _term.input(_input)
    true

primitive _TIOCGWINSZ
  fun apply(): ULong =>
    ifdef linux then
      21523
    elseif osx or bsd then
      1074295912
    else
      0
    end

actor Terminal
  """
  Handles terminal escape codes from stdin.
  """
  let _options: TermOptions val
  let _timers: Timers
  var _timer: (Timer tag | None) = None
  let _notify: TerminalNotify
  let _source: DisposableActor
  var _escape: _EscapeState = _EscapeNone
  var _esc_num: U8 = 0
  var _esc_mod: U8 = 0
  var _esc_mouse_x: U32 = 0
  var _esc_mouse_y: U32 = 0
  embed _esc_buf: Array[U8] = Array[U8]
  var _closed: Bool = false

  new create(
    notify: TerminalNotify iso,
    source: DisposableActor,
    timers: Timers = Timers,
    options: TermOptions val = TermOptions) =>
    """
    Create a new ANSI term.
    """
    _timers = timers
    _notify = consume notify
    _source = source
    _options = options

    ifdef not windows then
      SignalHandler(recover _TermResizeNotify(this) end, Sig.winch())
    end

    // Catch and send Ctrl-C (3) and Ctrl-Z (26) as inputs
    if _options.catch_ctrl_C then
      SignalHandler(recover _TermSigKeyNotify(this, Key.ctrl_C()) end, Sig.int())
    end
    
    if _options.catch_ctrl_Z then
      SignalHandler(recover _TermSigKeyNotify(this, Key.ctrl_Z()) end, Sig.tstp())
    end
    
    _size()

  be apply(data: Array[U8] iso) =>
    """
    Receives input from stdin.
    """
    if _closed then
      return
    end
    
    for c in (consume data).values() do
      match _escape
      | _EscapeNone =>
        if c == 0x1B then
          _escape = _EscapeStart
          _esc_buf.push(0x1B)
        else
          _notify(this, c)
        end
      | _EscapeStart => _in_escape_start(c)
      | _EscapeSS3 => _in_escape_SS3(c)
      | _EscapeCSI => _in_escape_CSI(c)
      | _EscapeMod => _in_escape_modifier(c)
      | _EscapeMouseStart => _in_escape_mouse_start(c)
      | _EscapeMouseX => _in_escape_mouse_X(c)
      | _EscapeMouseY => _in_escape_mouse_Y(c)
      end
    end

    // If we are in the middle of an escape sequence, set a timer for 25 ms.
    // If it fires, we send the escape sequence as if it was normal data.
    if _escape isnt _EscapeNone then
      if _timer isnt None then
        try _timers.cancel(_timer as Timer tag) end
      end

      let t = recover
        object is TimerNotify
          let term: Terminal = this

          fun ref apply(timer: Timer, count: U64): Bool =>
            term._timeout()
            false
        end
      end

      let timer = Timer(consume t, 25000000)
      _timer = timer
      _timers(consume timer)
    end

  fun ref _in_escape_start(c: U8) =>
    match c
    | 'b' => // alt-left
      _esc_mod = 3
      _left()
    | 'f' => // alt-right
      _esc_mod = 3
      _right()
    | 'O' =>
      _escape = _EscapeSS3
      _esc_buf.push(c)
    | '[' =>
      _escape = _EscapeCSI
      _esc_buf.push(c)
    else
      _esc_flush()
    end

  fun ref _in_escape_SS3(c: U8) =>
    match c
    | 'A' => _up()
    | 'B' => _down()
    | 'C' => _right()
    | 'D' => _left()
    | 'H' => _home()
    | 'F' => _end()
    | 'P' => _fn_key(1)
    | 'Q' => _fn_key(2)
    | 'R' => _fn_key(3)
    | 'S' => _fn_key(4)
    else
      _esc_flush()
    end

  fun ref _in_escape_CSI(c: U8) =>
    match c
    | 'A' => _up()
    | 'B' => _down()
    | 'C' => _right()
    | 'D' => _left()
    | 'H' => _home()
    | 'F' => _end()
    | '~' => _keypad()
    | '<' => 
      _escape = _EscapeMouseStart
    | ';' =>
      _escape = _EscapeMod
    | if (c >= '0') and (c <= '9') =>
      // Escape number.
      _esc_num = (_esc_num * 10) + (c - '0')
      _esc_buf.push(c)
    else
      _esc_flush()
    end

  fun ref _in_escape_modifier(c: U8) =>
    match c
    | 'A' => _up()
    | 'B' => _down()
    | 'C' => _right()
    | 'D' => _left()
    | 'H' => _home()
    | 'F' => _end()
    | '~' => _keypad()
    | if (c >= '0') and (c <= '9') =>
      // Escape modifier.
      _esc_mod = (_esc_mod * 10) + (c - '0')
      _esc_buf.push(c)
    else
      _esc_flush()
    end

  fun ref _in_escape_mouse_start(c: U8) =>
    match c
    | ';' =>
      _escape = _EscapeMouseX
    | if (c >= '0') and (c <= '9') =>
      // Escape number.
      _esc_num = (_esc_num * 10) + (c - '0')
      _esc_buf.push(c)
    else
      _esc_flush()
    end

  fun ref _in_escape_mouse_X(c: U8) =>
    match c
    | ';' =>
      _escape = _EscapeMouseY
    | if (c >= '0') and (c <= '9') =>
      // mouse x coordinate
      _esc_mouse_x = (_esc_mouse_x * 10) + (c - '0').u32()
      _esc_buf.push(c)
    else
      _esc_flush()
    end

  fun ref _in_escape_mouse_Y(c: U8) =>
    match c
    | 'M' =>
      match (_esc_num and 0b11100000)
      | 0 => _mouse_press()
      | 32 => if (_esc_num and 0b11) == 0b11 then _mouse_move() else _mouse_drag() end
      | 64 => _mouse_wheel(where dir=(_esc_num and 1))
      else 
        _esc_flush()
      end
    | 'm' =>
      if (_esc_num and 0b11100000) == 0 then
        _mouse_release()
      else 
        _esc_flush()
      end
    | if (c >= '0') and (c <= '9') =>
      // mouse y coordinate
      _esc_mouse_y = (_esc_mouse_y * 10) + (c - '0').u32()
      _esc_buf.push(c)
    else
      _esc_flush()
    end

  be prompt(value: String) =>
    """
    Pass a prompt along to the notifier.
    """
    _notify.prompt(this, value)

  be size() =>
    _size()

  be input(input': U8 val) =>
    """
    Pass the provided input to the notifier.
    """
    _notify(this, input')

  fun ref _size() =>
    """
    Pass the window size to the notifier.
    """
    let ws: _TermSize = _TermSize
    ifdef posix then
      @ioctl(0, _TIOCGWINSZ(), ws) // do error handling
      _notify.size(ws.row, ws.col)
    end

  be dispose() =>
    """
    Stop accepting input, inform the notifier we have closed, and dispose of
    our source.
    """
    if not _closed then
      _esc_clear()
      _notify.closed()
      _source.dispose()
      _closed = true
    end

  be _timeout() =>
    """
    Our timer since receiving an ESC has expired. Send the buffered data as if
    it was not an escape sequence.
    """
    _timer = None
    _esc_flush()

  fun ref _mouse_button() : MouseButton =>
    match (_esc_num and 0b00000011)
    | 0b00 => LeftMouseButton
    | 0b01 => MiddleMouseButton
    | 0b10 => RightMouseButton
    else
      UnknownMouseButton
    end

  fun ref _mouse_wheel(dir: U8) =>
    (let ctrl, let alt, let shift) = _mouse_kbd_mod()
    _notify.mouse_wheel(
      if dir == 0 then ScrollDown else ScrollUp end, 
      ctrl, alt, shift, _esc_mouse_x, _esc_mouse_y)
    _esc_clear()

  fun ref _mouse_drag() =>
    (let ctrl, let alt, let shift) = _mouse_kbd_mod()
    _notify.mouse_drag(_mouse_button(), ctrl, alt, shift, _esc_mouse_x, _esc_mouse_y)
    _esc_clear()

  fun ref _mouse_move() =>
    (let ctrl, let alt, let shift) = _mouse_kbd_mod()
    _notify.mouse_move(ctrl, alt, shift, _esc_mouse_x, _esc_mouse_y)
    _esc_clear()

  fun ref _mouse_release() =>
    (let ctrl, let alt, let shift) = _mouse_kbd_mod()
    _notify.mouse_release(_mouse_button(), ctrl, alt, shift, _esc_mouse_x, _esc_mouse_y)
    _esc_clear()

  fun ref _mouse_press() =>
    (let ctrl, let alt, let shift) = _mouse_kbd_mod()
    _notify.mouse_press(_mouse_button(), ctrl, alt, shift, _esc_mouse_x, _esc_mouse_y)
    _esc_clear()

  fun ref _mouse_kbd_mod(): (Bool, Bool, Bool) =>
    /*
     * Map the modifier bits in the mouse input code (_esc_num) to
     * a tuple of modifier booleans
     */
    match (_esc_num and 0b00011100)
                 //  ctrl   alt    shift
    | 0b00000100 => (false, false, true)
    | 0b00001000 => (false, true,  false)
    | 0b00010000 => (true,  false, false)
    | 0b00001100 => (false, true,  true)
    | 0b00010100 => (true,  false, true)
    | 0b00011000 => (true,  true,  false)
    | 0b00011100 => (true,  true,  true)
    else (false, false, false)
    end

  fun ref _mod(): (Bool, Bool, Bool) =>
    """
    Set the modifier bools.
    """
    let r = match _esc_mod
    | 2 => (false, false, true)
    | 3 => (false, true, false)
    | 4 => (false, true, true)
    | 5 => (true, false, false)
    | 6 => (true, false, true)
    | 7 => (true, true, false)
    | 8 => (true, true, true)
    else (false, false, false)
    end

    _esc_mod = 0
    r

  fun ref _keypad() =>
    """
    An extended key.
    """
    match _esc_num
    | 1 => _home()
    | 2 => _insert()
    | 3 => _delete()
    | 4 => _end()
    | 5 => _page_up()
    | 6 => _page_down()
    | 11 => _fn_key(1)
    | 12 => _fn_key(2)
    | 13 => _fn_key(3)
    | 14 => _fn_key(4)
    | 15 => _fn_key(5)
    | 17 => _fn_key(6)
    | 18 => _fn_key(7)
    | 19 => _fn_key(8)
    | 20 => _fn_key(9)
    | 21 => _fn_key(10)
    | 23 => _fn_key(11)
    | 24 => _fn_key(12)
    | 25 => _fn_key(13)
    | 26 => _fn_key(14)
    | 28 => _fn_key(15)
    | 29 => _fn_key(16)
    | 31 => _fn_key(17)
    | 32 => _fn_key(18)
    | 33 => _fn_key(19)
    | 34 => _fn_key(20)
    end

  fun ref _up() =>
    """
    Up arrow.
    """
    (let ctrl, let alt, let shift) = _mod()
    _notify.up(ctrl, alt, shift)
    _esc_clear()

  fun ref _down() =>
    """
    Down arrow.
    """
    (let ctrl, let alt, let shift) = _mod()
    _notify.down(ctrl, alt, shift)
    _esc_clear()

  fun ref _left() =>
    """
    Left arrow.
    """
    (let ctrl, let alt, let shift) = _mod()
    _notify.left(ctrl, alt, shift)
    _esc_clear()

  fun ref _right() =>
    """
    Right arrow.
    """
    (let ctrl, let alt, let shift) = _mod()
    _notify.right(ctrl, alt, shift)
    _esc_clear()

  fun ref _delete() =>
    """
    Delete key.
    """
    (let ctrl, let alt, let shift) = _mod()
    _notify.delete(ctrl, alt, shift)
    _esc_clear()

  fun ref _insert() =>
    """
    Insert key.
    """
    (let ctrl, let alt, let shift) = _mod()
    _notify.insert(ctrl, alt, shift)
    _esc_clear()

  fun ref _home() =>
    """
    Home key.
    """
    (let ctrl, let alt, let shift) = _mod()
    _notify.home(ctrl, alt, shift)
    _esc_clear()

  fun ref _end() =>
    """
    End key.
    """
    (let ctrl, let alt, let shift) = _mod()
    _notify.end_key(ctrl, alt, shift)
    _esc_clear()

  fun ref _page_up() =>
    """
    Page up key.
    """
    (let ctrl, let alt, let shift) = _mod()
    _notify.page_up(ctrl, alt, shift)
    _esc_clear()

  fun ref _page_down() =>
    """
    Page down key.
    """
    (let ctrl, let alt, let shift) = _mod()
    _notify.page_down(ctrl, alt, shift)
    _esc_clear()

  fun ref _fn_key(i: U8) =>
    """
    Function key.
    """
    (let ctrl, let alt, let shift) = _mod()
    _notify.fn_key(i, ctrl, alt, shift)
    _esc_clear()

  fun ref _esc_flush() =>
    """
    Pass a partial or unrecognised escape sequence to the notifier.
    """
    for c in _esc_buf.values() do
      _notify(this, c)
    end

    _esc_clear()

  fun ref _esc_clear() =>
    """
    Clear the escape state.
    """
    if _timer isnt None then
      try _timers.cancel(_timer as Timer tag) end
      _timer = None
    end
    _escape = _EscapeNone
    _esc_buf.clear()
    _esc_num = 0
    _esc_mod = 0
    _esc_mouse_x = 0
    _esc_mouse_y = 0

