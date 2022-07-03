use "../../termax"

class _Listen is TerminalNotify
  let _out: OutStream

  new iso create(env': Env) => 
    _out = env'.out
    _out.print("Press Ctrl-C to exit.\nType away ...")

  fun ref apply(term: Terminal ref, input: U8 val) =>
    match input
    | 3 => term.dispose()
    | if (input >= 32) and (input < 127) => _out.write([input])
    else _out.>write("[" + input.string() + "]")
    end

actor Main
  new create(env: Env) =>
    let term = EasyTerminal(env, _Listen(env))
