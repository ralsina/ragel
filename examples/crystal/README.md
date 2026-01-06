# Crystal Code Generation with Ragel

This directory contains examples of using Ragel to generate Crystal code for state machines.

## Quick Start

### Generate Crystal Code

Use the `-Y` flag to specify Crystal as the host language:

```bash
# Table-style (default, recommended)
ragel -Y -o output.cr input.rl

# Fast table-style
ragel -T1 -Y -o output.cr input.rl

# Flat-style (not yet implemented)
ragel -F0 -Y -o output.cr input.rl  # TODO
```

### Compile and Run

```bash
crystal build output.cr -o program
./program
```

## Examples

### atoi.rl
A simple example that converts a string to an integer.

```bash
ragel -Y -o atoi.cr atoi.rl
crystal build atoi.cr -o atoi
echo "-123" | ./atoi  # Output: -123
```

### rpn.rl
A Reverse Polish Notation calculator with a stack.

```bash
ragel -Y -o rpn.cr rpn.rl
crystal build rpn.cr -o rpn
echo "4 3 +" | ./rpn  # Output: 7
```

## Code Styles

Crystal currently supports **table-style** code generation:

| Style | Flag | Status | Notes |
|-------|------|--------|-------|
| Table | `-T0` or `-T1` | ✅ Working | Default, recommended for most use cases |
| Flat | `-F0` or `-F1` | ⏳ Planned | Not yet implemented |
| Fast-Flat | `-F1` | ⏳ Planned | Not yet implemented |
| Goto | `-G0`, `-G1`, `-G2` | ❌ Not Possible | Crystal has no goto statement |

## Limitations

Crystal code generation has some limitations compared to other languages:

### Unsupported Features

1. **fgoto, fcall, fret** - These features require goto-style code generation, which is not possible in Crystal due to the lack of a `goto` statement.

2. **Complex token buffers** - Advanced use of `ts` and `te` variables in conjunction with fgoto/fcall/fret may not work.

### What Works Well

Crystal code generation works great for:
- ✅ Simple to moderate state machines
- ✅ Pattern matching and scanning
- ✅ Lexical analysis without complex control flow
- ✅ Action blocks with Crystal code
- ✅ Standard state machine features (actions, transitions, conditions)

## Crystal-Specific Adaptations

The Crystal code generator was adapted from the Ruby generator with the following changes:

1. **Constant naming**: Constants must start with uppercase (A-Z) for function access
2. **Variable initialization**: No `||=` for undefined variables; explicit `=` required
3. **Break statements**: Changed from `begin...end` to `loop do...break...end` where needed
4. **Type system**: Crystal is statically typed, unlike Ruby

## Migration from Ruby to Crystal

If you have Ragel `.rl` files written for Ruby, you can often use them with Crystal with minimal changes:

1. Change Ruby-specific types to Crystal types:
   - `Fixnum` → `Int32` or `Int64`
   - Add type annotations to method signatures

2. Update Ruby idioms:
   - `attr_accessor` → Crystal property syntax
   - `class << self` → `def self.method_name`

3. Ensure variables are initialized before use (no `||=` on undefined variables)

Example:

```ruby
# Ruby
def process(data)
  result ||= 0  # Ruby allows this
  ...
end
```

```crystal
# Crystal
def process(data : String) : Int32
  result = 0  # Crystal requires initialization
  ...
end
```

## Performance Tips

1. **Use table-style** for most cases (default with `-T0`)
2. **Use fast table-style** (`-T1`) for better performance in hot loops
3. **Crystal's static typing** gives better performance than Ruby

## Troubleshooting

### "undefined local variable or method" Error

This usually means a constant needs to be uppercase. The code generator handles this automatically for machine-specific constants (e.g., `Atoi_start`), but you may need to adjust user-defined constants.

### "break outside of loop" Error

This can occur with certain action patterns. The generator uses `loop do` blocks to support break statements where needed.

### Type Errors

Crystal requires explicit type annotations for method parameters and return values:

```crystal
# Add type annotations
def my_method(data : String) : Int32
  # ...
end
```

## See Also

- **LIMITATIONS.md** - Detailed information about unsupported features
- **Ragel Documentation** - https://www.colm.net/open-source/ragel/
- **Crystal Language** - https://crystal-lang.org/

## Contributing

When adding new examples:
1. Keep them simple and focused
2. Avoid fgoto/fcall/fret features
3. Include test cases demonstrating usage
4. Document any Crystal-specific considerations

## Status

**Current Version**: Table-style generation fully functional ✅

**Planned**:
- Flat-style code generation
- Fast-flat code generation
- More comprehensive examples
- Automated test suite
