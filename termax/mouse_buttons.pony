primitive LeftMouseButton
  fun string() : String => "Left"
primitive MiddleMouseButton
  fun string() : String => "Middle"
primitive RightMouseButton
  fun string() : String => "Right"
primitive UnknownMouseButton
  fun string() : String => "Unknown"

type KnownMouseButton is (LeftMouseButton | MiddleMouseButton | RightMouseButton)
type MouseButton is (KnownMouseButton | UnknownMouseButton)

primitive ScrollUp
  fun string() : String => "Up"
primitive ScrollDown
  fun string() : String => "Down"

type ScrollDirection is (ScrollUp | ScrollDown)
