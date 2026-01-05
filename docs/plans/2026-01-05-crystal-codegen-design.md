# Crystal Code Generation for Ragel

**Date**: 2026-01-05
**Status**: Design Complete

## Overview

Add Crystal as a target language for Ragel code generation, starting with table-style output only.

Crystal and Ruby share very similar syntax, so we can leverage the existing Ruby code generator with minimal changes. The implementation will create new Crystal-specific files copied from the Ruby code generator, adapted for Crystal's syntax and semantics.

## Goals

- Generate idiomatic Crystal code that compiles and runs with Crystal's compiler
- Support table-style code generation initially
- Rely on Crystal's type inference to minimize explicit type annotations
- Create clean separation from Ruby code generation for easier maintenance

## Implementation Plan

### New Files

1. **`ragel/crystalcodegen.h`** - Header defining `CrystalCodeGen` class
2. **`ragel/crystalcodegen.cpp`** - Main Crystal code generator implementation
3. **`ragel/crystaltable.h`** - Header for table-style Crystal generator
4. **`ragel/crystaltable.cpp`** - Table-style Crystal code generation

### Files to Modify

1. **`ragel/Makefile.am`** - Add Crystal files to build sources
2. **`ragel/main.cpp`** - Add `-Z` command-line option and Crystal code generator instantiation
3. **`configure.ac`** - Add Crystal as recognized target language
4. **`test/runtests.in`** - Eventually add `-Z` option for Crystal testing

### Adaptation Strategy

Copy from Ruby implementation:
- `rubycodegen.cpp` → `crystalcodegen.cpp`
- `rubycodegen.h` → `crystalcodegen.h`
- `rubytable.cpp` → `crystaltable.cpp`
- `rubytable.h` → `crystaltable.h`

Make changes:
1. Replace `RubyCodeGen` with `CrystalCodeGen`
2. Replace `ruby` with `crystal` (case-sensitive)
3. Change output file extension from `.rb` to `.cr`
4. Adjust Ruby-specific idioms for Crystal
5. Handle type annotation requirements where inference isn't sufficient

### Key Differences Between Ruby and Crystal

**Similarities** (no changes needed):
- Comment syntax (`#`)
- String/symbol syntax
- Array/hash syntax
- Basic control structures

**Differences** (need handling):
- Crystal is statically typed with type inference
- Crystal's standard library differs from Ruby's
- No Ruby metaprogramming (not relevant for generated code)
- Different memory management (shouldn't affect scanner code)

### Build Integration

**Command-line Option**: `-Z` (continuing the pattern: `-C`, `-D`, `-J`, `-R`)

**Integration Pattern**: Follow Ruby's approach in `main.cpp`:
- Detect `-Z` flag
- Create `CrystalCodeGen` instance
- Use table-style generation (only style supported initially)

**No Compiler Check**: Unlike some languages, we don't need to check for Crystal at configure time since we're generating source code, not binaries.

## Testing

### Initial Test Case

Use existing test files (e.g., `test/atoi1.rl`) to validate:
- Scanner builds correctly
- Crystal syntax is valid
- Basic state machine logic works

### Testing Process

1. Generate Crystal code:
   ```bash
   ragel -Z -o test_atoi.cr test/atoi1.rl
   ```

2. Inspect generated code for syntax issues

3. Compile with Crystal:
   ```bash
   crystal build test_atoi.cr
   ```

4. Fix any compilation errors by adjusting code generator

5. Run and verify correct behavior

### Expected Issues

- Missing type annotations where Crystal's inference fails
- Ruby standard library calls not available in Crystal
- Syntax differences in edge cases

## Future Work

After validating table-style generation:
- Add additional code styles (flat, goto, etc.)
- Integrate with automated test suite (TXL transformations)
- Add Crystal-specific optimizations
- Document Crystal-specific usage patterns

## Documentation Updates

After implementation:
- Update README.md to list Crystal as supported language
- Add Crystal examples if appropriate
- Document limitations (table-style only initially)
- Note any Crystal-specific considerations
