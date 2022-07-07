use "../../termax"

class _Listen is (TerminalNotify & TerminalTextFormatting)
  let _out: OutStream

  new iso create(env': Env) => 
    _out = env'.out
    _out.print(color_with(" ^R ", Term.red()) 
                   + color_with(" ^G ", Term.green()) 
                   + color_with(" ^B ", Term.blue())
                   + "- Reset " + invert(" ^R ")
                   + "- Quit " + invert(" ^C ")
                   + "\nType away ...")

  fun ref _reset_all() =>
    _out.write(Term.reset())

  fun ref closed() =>
    _reset_all()
    _out.print("\n\nBye")

  fun ref apply(term: Terminal ref, input: U8 val) =>
    match input
    | Key.ctrl_R() => 
      _out.write(Term.red())
    | Key.ctrl_G() => 
      _out.write(Term.green())
    | Key.ctrl_B() => 
      _out.write(Term.blue())
    | Key.ctrl_C() => term.dispose()
    | Key.ctrl_R() => _reset_all()
    | Key.back_space() => _out.write(Term.left() + Term.erase(EraseAfter))
    | if (input >= 32) and (input < 127) => _out.write([input])
    else _out.>write(invert("[" + input.string() + "]"))
    end

actor Main
  new create(env: Env) =>
    let term = EasyTerminal(env, _Listen(env))
