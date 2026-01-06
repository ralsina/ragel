# Crystal Code Generator - Limitations and Status

## Current Implementation Status

### Supported Code Styles
- ✅ **Table-style** (`-T0` or `-T1`): Fully functional and tested
- ⏳ **Flat-style** (`-F0` or `-F1`): Not yet implemented
- ❌ **Goto-style** (`-G0`, `-G1`, `-G2`): **Not possible** - Crystal has no `goto` statement

### Unsupported Ragel Features

The following Ragel features are **NOT available** in Crystal code generation:

#### 1. fgoto, fcall, fret
- **Why**: These features require goto-style code generation
- **Status**: Cannot be implemented without goto statements
- **Workaround**: Restructure your state machine to use explicit state transitions instead
- **Examples that won't work**: `gotocallret.rl`, `clang.rl` (advanced usage)

#### 2. Token Buffer Variables (ts, te) in Complex Scenarios
- **Why**: These interact with fgoto/fcall/fret in advanced patterns
- **Status**: Basic usage may work, but advanced patterns are untested
- **Examples that may fail**: `clang.rl`

### What Works Well

Crystal code generation works great for:
- ✅ Simple state machines (e.g., `atoi.rl`, `rpn.rl`)
- ✅ Pattern matching and scanning
- ✅ Lexical analysis without complex control flow
- ✅ Action blocks with Crystal code
- ✅ Standard state machine features (actions, transitions, conditions)

### Implementation Details

The Crystal code generator was created by adapting the Ruby code generator due to syntactic similarities. Key adaptations include:

1. **Constant naming**: Constants must start with uppercase (A-Z) for function access
2. **Variable initialization**: No `||=` for undefined variables; must use `=`
3. **Break statements**: Changed from `begin...end` to `loop do...break...end`
4. **Type system**: Crystal is statically typed, unlike Ruby

### Future Work

Priority tasks for improving Crystal support:

1. **Implement flat-style code generation** (high priority)
   - Better performance than table-style
   - Doesn't require goto statements
   - Model after `rubyflat.cpp` and `rubyfflat.cpp`

2. **Add more examples** (medium priority)
   - Simple scanners (scan1.rl, scan2.rl)
   - URL parsing (url.rl)
   - Conditional state machines (cond.rl)
   - Avoid examples using fgoto/fcall/fret

3. **Testing infrastructure** (medium priority)
   - Automated tests for generated code
   - Validation against known-good outputs

4. **Documentation** (low priority)
   - User guide for Crystal code generation
   - Migration guide from Ruby to Crystal

### Comparison with Other Languages

| Language | Table | Flat | Fast-Flat | Goto | fgoto/fcall/fret |
|----------|-------|------|-----------|------|------------------|
| C        | ✅    | ✅   | ✅        | ✅   | ✅               |
| C#       | ✅    | ✅   | ✅        | ✅   | ✅               |
| D        | ✅    | ✅   | ✅        | ✅   | ✅               |
| Go       | ✅    | ❌   | ❌        | ❌   | ❌               |
| Java     | ✅    | ✅   | ✅        | ✅   | ✅               |
| OCaml    | ✅    | ✅   | ❌        | ✅   | ✅               |
| Ruby     | ✅    | ✅   | ✅        | ⚠️   | ⚠️ (exp)        |
| Crystal  | ✅    | ❌   | ❌        | ❌   | ❌               |

Legend: ✅ = Supported, ❌ = Not supported, ⚠️ = Experimental

### Notes

- Ruby's goto-style (`rbxgoto`) is marked as "very experimental" and only works with Rubinius
- Crystal will never support goto-style without fundamental language changes
- Flat-style generation is the best path for performance improvements in Crystal

### References

- Ragel code generation styles: See `ragel --help` under "code style"
- Ruby implementation: `ragel/rubycodegen.cpp`, `ragel/rubyflat.cpp`
- Crystal implementation: `ragel/crystalcodegen.cpp`, `ragel/crystaltable.cpp`
