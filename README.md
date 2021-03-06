# Termax for Pony

> Not ready for production yet. Expect API changes for a little while.

The `termax` package provides support for building text-based user interfaces for terminals. This package is based on the standard library's `term` package, offering backward compatibilti while adding functionality to help build richer text-based UIs.

## API Documentation'

https://nogginly.github.io/termax.pony/

### Core API Overview

| Object                             | Type        | Summary                                                                       |
| ---------------------------------- | ----------- | ----------------------------------------------------------------------------- |
| `TerminalNotify`                   | *interface* | Implement this when setting up input handling                                 |
| `TermOptions`                      | class       | Create an instance to configure `Terminal` if you want to change the defaults |
| `Terminal`                         | actor       | Sets up an interactive terminal and sends input events via `TerminalNotify`   |
| &nbsp;&nbsp;`└── EasyTerminal`     | primitive   | Use to create a pre-configured Terminal that uses standard input.             |
| *`TerminalEscapeCodes`*            | *trait*     | Defines functions that return the ANSI and other terminal escape codes        |
| &nbsp;&nbsp;`└── Term`             | primitive   | Use to get escape codes                                                       |
| *`TerminalTextFormatting`*         | *trait*     | Defines convenient text formatting functions                                  |
| &nbsp;&nbsp;`└── TermText`         | primitive   | Use to format text                                                            |
| *`TerminalDrawing`*                | *trait*     | Defines convenient text formatting functions                                  |
| &nbsp;&nbsp;`└── TermDraw`         | primitive   | Use to format text                                                            |
| *`GridChars`*                      | *trait*     | Defines line style characters used when drawing box/grids                     |
| &nbsp;&nbsp;`└── SingleSolidLine`  | primitive   | Single solid line style                                                       |
| &nbsp;&nbsp;`└── SingleDashedLine` | primitive   | Single dashed line style                                                      |
| &nbsp;&nbsp;`└── DoubleSolidLine`  | primitive   | Double solid line style                                                       |
| `FillPattern`                      | primitive   | Convenient list of characters that are useful as fill patterns.               |

## Compatibility

Rhe following objects are available for compatibility with `term` in the standard library.

* `ANSI` with functions to obtain the escape/control codes
* `ANSINotify` which defines the interface for events from the terminal control
* `ANSITerm` which is used to setup the terminal input processing.

## Enhancements

In addition to the functionality provided by the standard library's `term` package, `termax` adds the following capabilities:

* Mouse input handling
* Screen switching between normal and alternate buffers
* Improved cursor management, including hiding the cursor
* Capturing SIGINT and SIGTSTP to support `Ctrl-C` and `Ctrl-Z` as regular inputs

## Installation

* Install [corral](https://github.com/ponylang/corral)
* `corral add github.com/nogginly/termax.pony.git`
* `corral fetch` to fetch your dependencies
* `use "termax"` to include this package
* `corral run -- ponyc` to compile your application

## Examples

### Simple

Build the example with `ponyc -o bin examples/simple` and run `bin/simple` to launch it.

```pony
use "termax"

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
```
### Mousing

Build the mouse-handling example with `ponyc -o bin examples/mousing` and run `bin/mousing` to launch it. The following shows the example in use.

![Mousing example video](docs/images/termax.mousing.gif)

### Drawing

Build the drawing example with `ponyc -o bin examples/drawing` and run `bin/drawing` to launch it. The following shows the example in use.

![Drawing example screenshot](docs/images/termax.drawing.png)

### Using Corral

The `using_corral` can be used to test using `termax` via corral. Run the following commands to build the example:

```sh
cd examples/using_corral
corral fetch
corral run -- ponyc -o bin
```

Now you can run `bin/using_corral` to try the app.

## Contributing

Bug reports and sugestions are welcome. Otherwise, at this time, this project is closed for code changes and pull requests. I appreciate your understanding.

This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](CODE_OF_CONDUCT.md).

## License

The library is available as open source under the terms of the [BSD-2 License](LICENSE).

## References

1. Build your own Command Line with ANSI escape codes - https://www.lihaoyi.com/post/BuildyourownCommandLinewithANSIescapecodes.html
2. ANSI Escape Sequences - https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
3. Everything you never wanted to know about ANSI escape codes - https://notes.burke.libbey.me/ansi-escape-codes/
4. Turn on raw mode in terminal using <termios.h> - https://viewsourcecode.org/snaptoken/kilo/02.enteringRawMode.html
5. XTerm Control Sequences - https://invisible-island.net/xterm/ctlseqs/ctlseqs.html
6. Complete list of ASCII codes - https://theasciicode.com.ar/ascii-codes.txt
