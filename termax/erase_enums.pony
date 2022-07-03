
primitive EraseBefore
  """
  Erase up to to (before) the cursor position
  """

primitive EraseAfter
  """
  Erase from (after) the cursor position
  """

primitive EraseAll
  """
  Erase all (before and after) regardless of cursor position
  """

type EraseLine is (EraseBefore | EraseAfter | EraseAll)
  """
  Erase the line relative to the cursor position.
  """

type EraseDisplay is (EraseBefore | EraseAfter | EraseAll)
  """
  Erase the display (screen) relative to the cursor position.
  """
