
primitive Key
  """
  Names for non-text input keys received via `TerminalNotify.apply()`
  """
  fun ctrl_A() : U8 => 1
  fun ctrl_B() : U8 => 2
  fun ctrl_C() : U8 => 3
  fun ctrl_D() : U8 => 4
  fun ctrl_E() : U8 => 5
  fun ctrl_F() : U8 => 6
  fun ctrl_G() : U8 => 7
  fun ctrl_H() : U8 => 8
  fun ctrl_I() : U8 => 9
  fun ctrl_J() : U8 => 10
  fun ctrl_K() : U8 => 11
  fun ctrl_L() : U8 => 12
  fun ctrl_M() : U8 => 13
  fun ctrl_N() : U8 => 14
  fun ctrl_O() : U8 => 15
  fun ctrl_P() : U8 => 16
  fun ctrl_Q() : U8 => 17
  fun ctrl_R() : U8 => 18
  fun ctrl_S() : U8 => 19
  fun ctrl_T() : U8 => 20
  fun ctrl_U() : U8 => 21
  fun ctrl_V() : U8 => 22
  fun ctrl_W() : U8 => 23
  fun ctrl_X() : U8 => 24
  fun ctrl_Y() : U8 => 25
  fun ctrl_Z() : U8 => 26

  fun tab() : U8 => ctrl_I()
  fun enter() : U8 => ctrl_J()
  fun escape() : U8 => 27
  fun esc() : U8 => escape()
  fun back_space() : U8 => 127
