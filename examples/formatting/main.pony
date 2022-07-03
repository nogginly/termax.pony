use "../../termax"

class _Listen is (TerminalNotify & TerminalTextFormatting)
  let _out: OutStream
  var _bold: Bool = false
  var _faint: Bool = false
  var _italics: Bool = false
  var _underline: Bool = false
  var _strikeout: Bool = false

  new iso create(env': Env) => 
    _out = env'.out
    _out.print(bold("Bold ") + invert(" ^B ") + " - "
                   + faint("Faint ") + invert(" ^F ") + " - "
                   + italics("Italics ") + invert(" ^I ") + " - "
                   + underline("Underline ") + invert(" ^U ") + " - "
                   + strikeout("Strikeout ") + invert(" ^S ")
                   + "- Reset " + invert(" ^R ")
                   + "- Quit " + invert(" ^C ")
                   + "\nType away ...")

  fun ref _reset_all() =>
    _out.write(Term.reset())
    _bold = false
    _italics = false
    _underline = false
    _strikeout = false

  fun ref closed() =>
    _out.print("\n\nBye")

  fun ref apply(term: Terminal ref, input: U8 val) =>
    match input
    | Key.ctrl_B() => 
      _bold = not _bold
      _out.write(Term.bold(_bold))
    | Key.ctrl_C() => term.dispose()
    | Key.ctrl_F() => 
      _faint = not _faint
      _out.write(Term.faint(_faint))
    | Key.ctrl_I() => 
      _italics = not _italics
      _out.write(Term.italics(_italics))
    | Key.ctrl_R() => _reset_all()
    | Key.ctrl_S() => 
      _strikeout = not _strikeout
      _out.write(Term.strikeout(_strikeout))
    | Key.ctrl_U() => 
      _underline = not _underline
      _out.write(Term.underline(_underline))
    | Key.back_space() => _out.write(Term.left() + Term.erase(EraseAfter))
    | if (input >= 32) and (input < 127) => _out.write([input])
    else _out.>write(invert("[" + input.string() + "]"))
    end

actor Main
  new create(env: Env) =>
    let term = EasyTerminal(env, _Listen(env))
