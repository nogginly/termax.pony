
// Defining ANSI primtive to be compatible with
// standard library's `term` package.
primitive ANSI is TerminalEscapeCodes

// Defining ANSITerm type alias to be compatible with
// standard library's `term` package.
type ANSITerm is Terminal

// Defining ANSINotify interface to be compatible with
// standard library's `term` package.
interface ANSINotify is TerminalNotify
