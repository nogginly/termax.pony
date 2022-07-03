primitive EasyTerminal
  """
  Convenient way to setup the `Terminal` using standard input from the environment.
  """
  fun apply(env: Env, notify': TerminalNotify iso) : Terminal =>
    """
    Create a `Terminal` using standard input from `env`, configured to
    capture Ctrl-C and Ctrl-Z as input.
    """
    let term = Terminal(consume notify', env.input where 
                        options = TermOptions(where 
                                      capture_ctrl_c=true, 
                                      capture_ctrl_z=true))
    env.input(object iso is InputNotify
                fun ref apply(data: Array[U8] iso) =>
                  term(consume data)
              end, 128)
    term
