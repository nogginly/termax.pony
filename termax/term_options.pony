
class val TermOptions
  let catch_ctrl_C : Bool
  let catch_ctrl_Z : Bool

  new val create(capture_ctrl_c: Bool = false, capture_ctrl_z: Bool = false) =>
  """
    Default options are backwards compatible.
  """
    catch_ctrl_C = capture_ctrl_c
    catch_ctrl_Z = capture_ctrl_z
