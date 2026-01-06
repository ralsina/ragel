# Crystal Code Generation Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add Crystal as a target language for Ragel code generation, supporting table-style output

**Architecture:** Create Crystal-specific code generator classes by copying and adapting Ruby code generators. Crystal's syntax is very similar to Ruby, so changes will be minimal: file extensions, class names, and minor syntax adjustments.

**Tech Stack:** C++ (Ragel codebase), Ragel (scanner/parser generator), Kelbt (parser generator), Crystal (target language)

---

## Task 1: Create Crystal Code Generator Header

**Files:**
- Create: `ragel/crystalcodegen.h`
- Reference: `ragel/rubycodegen.h`

**Step 1: Copy Ruby code generator header to Crystal**

```bash
cp ragel/rubycodegen.h ragel/crystalcodegen.h
```

**Step 2: Replace RubyCodeGen with CrystalCodeGen**

Run: `sed -i 's/RubyCodeGen/CrystalCodeGen/g' ragel/crystalcodegen.h`

**Step 3: Update header guards and includes**

Edit `ragel/crystalcodegen.h`, change line ~25-30:

```cpp
#ifndef _CRYSTALCODEGEN_H
#define _CRYSTALCODEGEN_H

/*
 *  Copyright 2001-2007 Adrian Thurston <thurston@complang.org>
 *  Crystal code generation adapted 2025
 */

/*  This file is part of Ragel.
 *
 *  Ragel is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *  ...
 */
```

**Step 4: Update file output extension from .rb to .cr**

Find the line in `crystalcodegen.h` that specifies output file extension (search for ".rb") and change it:

```cpp
// Find and replace:
const char *outputExtension() { return ".cr"; }
```

**Step 5: Verify the header file compiles**

Run: `g++ -c -I../aapl ragel/crystalcodegen.h -o /tmp/test.o 2>&1 | head -20`
Expected: No errors (header files don't compile on their own, this just checks syntax)

**Step 6: Commit**

```bash
git add ragel/crystalcodegen.h
git commit -m "Add Crystal code generator header based on Ruby"
```

---

## Task 2: Create Crystal Code Generator Implementation

**Files:**
- Create: `ragel/crystalcodegen.cpp`
- Reference: `ragel/rubycodegen.cpp`

**Step 1: Copy Ruby code generator implementation to Crystal**

```bash
cp ragel/rubycodegen.cpp ragel/crystalcodegen.cpp
```

**Step 2: Replace all occurrences of RubyCodeGen with CrystalCodeGen**

Run: `sed -i 's/RubyCodeGen/CrystalCodeGen/g' ragel/crystalcodegen.cpp`

**Step 3: Replace ruby with crystal in identifiers (case-sensitive)**

Run: `sed -i 's/crystalcodegen/crystalcodegen/g; s/rubyCodeGen/crystalCodeGen/g' ragel/crystalcodegen.cpp`

**Step 4: Update copyright notice**

Edit `ragel/crystalcodegen.cpp`, add line after line 7:

```cpp
/*
 *  Copyright 2001-2007 Adrian Thurston <thurston@complang.org>
 *  Crystal code generation adapted 2025
 */
```

**Step 5: Update include statement**

Edit `ragel/crystalcodegen.cpp`, line ~30:

```cpp
#include "crystalcodegen.h"
```

**Step 6: Commit**

```bash
git add ragel/crystalcodegen.cpp
git commit -m "Add Crystal code generator implementation based on Ruby"
```

---

## Task 3: Create Crystal Table Code Generator Header

**Files:**
- Create: `ragel/crystaltable.h`
- Reference: `ragel/rubytable.h`

**Step 1: Copy Ruby table generator header to Crystal**

```bash
cp ragel/rubytable.h ragel/crystaltable.h
```

**Step 2: Replace RubyTabCodeGen with CrystalTabCodeGen**

Run: `sed -i 's/RubyTabCodeGen/CrystalTabCodeGen/g' ragel/crystaltable.h`

**Step 3: Update header guards**

Edit `ragel/crystaltable.h`, lines ~25-27:

```cpp
#ifndef _CRYSTALTABLE_H
#define _CRYSTALTABLE_H
```

**Step 4: Update include statement**

Edit `ragel/crystaltable.h`, find and replace:

```cpp
#include "crystalcodegen.h"
```

**Step 5: Commit**

```bash
git add ragel/crystaltable.h
git commit -m "Add Crystal table code generator header based on Ruby"
```

---

## Task 4: Create Crystal Table Code Generator Implementation

**Files:**
- Create: `ragel/crystaltable.cpp`
- Reference: `ragel/rubytable.cpp`

**Step 1: Copy Ruby table generator implementation to Crystal**

```bash
cp ragel/rubytable.cpp ragel/crystaltable.cpp
```

**Step 2: Replace RubyTabCodeGen with CrystalTabCodeGen**

Run: `sed -i 's/RubyTabCodeGen/CrystalTabCodeGen/g' ragel/crystaltable.cpp`

**Step 3: Replace ruby with crystal in identifiers**

Run: `sed -i 's/rubytable/crystaltable/g; s/rubyTab/crystalTab/g' ragel/crystaltable.cpp`

**Step 4: Update copyright notice**

Edit `ragel/crystaltable.cpp`, add after line 7:

```cpp
/*
 *  Copyright 2001-2007 Adrian Thurston <thurston@complang.org>
 *  Crystal code generation adapted 2025
 */
```

**Step 5: Update include statement**

Edit `ragel/crystaltable.cpp`, line ~30:

```cpp
#include "crystaltable.h"
```

**Step 6: Commit**

```bash
git add ragel/crystaltable.cpp
git commit -m "Add Crystal table code generator implementation based on Ruby"
```

---

## Task 5: Update Makefile.am to Build Crystal Files

**Files:**
- Modify: `ragel/Makefile.am`

**Step 1: Find the Ruby source files in Makefile.am**

View: `grep -n "ruby" ragel/Makefile.am`

Expected output shows lines like:
```
rubycodegen.h rubytable.h rubytable.cpp rubyftable.h rubyftable.cpp \
```

**Step 2: Add Crystal files to ragel_SOURCES**

Edit `ragel/Makefile.am`, add Crystal files after Ruby files (around line 40):

```makefile
ragel_SOURCES = \
	...existing files... \
	rubycodegen.h rubytable.h rubytable.cpp rubyftable.h rubyftable.cpp \
	crystalcodegen.h crystaltable.h crystaltable.cpp \
	...remaining files...
```

**Step 3: Verify Makefile.am syntax**

Run: `cat ragel/Makefile.am | grep -A5 -B5 "crystal"`
Expected: Crystal files listed in sources

**Step 4: Regenerate build files**

Run: `./autogen.sh`
Expected: autogen completes successfully with warnings but no errors

**Step 5: Reconfigure**

Run: `./configure --prefix=/usr/local --disable-manual`
Expected: Configure completes successfully

**Step 6: Commit**

```bash
git add ragel/Makefile.am
git commit -m "Add Crystal code generator files to build"
```

---

## Task 6: Integrate Crystal Option in main.cpp

**Files:**
- Modify: `ragel/main.cpp`

**Step 1: Find Ruby language detection in main.cpp**

Run: `grep -n "langId == RL_RUBY" ragel/main.cpp | head -5`

Note the line numbers for reference.

**Step 2: Find enum definition for languages**

Run: `grep -n "enum.*Lang" ragel/main.cpp -A20`

Look for enum with RL_RUBY, RL_JAVA, etc.

**Step 3: Add Crystal to language enum**

Edit `ragel/main.cpp`, add to language enum (usually around line 150-200):

```cpp
enum LangId
{
    RL_C,
    RL_D,
    RL_JAVA,
    RL_RUBY,
    RL_CSHARP,
    RL_GO,
    RL_OCAML,
    RL_CRYSTAL    // Add this line
};
```

**Step 4: Add command-line option parsing for Crystal**

Find where Ruby option is parsed (search for "-R") and add Crystal after it.

Run: `grep -n "\"-R\"" ragel/main.cpp -B2 -A2`

Add similar code for Crystal:

```cpp
else if ( strcmp( argv[i], "-Z" ) == 0 ) {
    // Check for duplicate language specs
    if ( hostLang != 0 )
        error() << "multiple language specifications given";
    hostLang = RL_CRYSTAL;
    codeStyle = GenTables;  // Crystal starts with table style only
}
```

**Step 5: Find Ruby code generator instantiation**

Run: `grep -n "case RL_RUBY:" ragel/main.cpp -A10`

Copy this pattern and add Crystal case:

```cpp
case RL_CRYSTAL:
{
    switch ( codeStyle ) {
    case GenTables:
        codeGen = new CrystalTabCodeGen( outStream );
        break;
    default:
        error() << "table style is currently the only style supported for Crystal\n";
        break;
    }
    break;
}
```

**Step 6: Add Crystal to usage/help output**

Find where Ruby is mentioned in help text and add Crystal:

Run: `grep -n "Ruby" ragel/main.cpp | grep -i "lang\|target\|output"`

Add similar help text for Crystal.

**Step 7: Commit**

```bash
git add ragel/main.cpp
git commit -m "Add Crystal language option to main.cpp"
```

---

## Task 7: Build and Test Basic Generation

**Files:**
- Test: `test/atoi1.rl`

**Step 1: Rebuild Ragel with Crystal support**

Run: `make clean && make -j$(nproc)`
Expected: Build completes with warnings but no errors

**Step 2: Verify ragel binary recognizes -Z option**

Run: `./ragel/ragel --help 2>&1 | grep -i crystal`
Expected: No output initially (help text not updated yet) or shows Crystal

**Step 3: Test Crystal code generation on atoi example**

Run: `./ragel/ragel -Z -o /tmp/atoi1.cr test/atoi1.rl`
Expected: File `/tmp/atoi1.cr` is created

**Step 4: Check generated Crystal file exists**

Run: `ls -lh /tmp/atoi1.cr`
Expected: File exists with non-zero size

**Step 5: Inspect generated Crystal code**

Run: `head -50 /tmp/atoi1.cr`

Look for:
- Ruby-specific constructs that need fixing
- `.rb` references (should be `.cr`)
- Obvious syntax issues

**Step 6: Document any issues found**

If there are obvious problems, note them for the next task.

Expected: Some Ruby-isms might need fixing

**Step 7: Commit if generation works**

```bash
# Only if basic generation succeeded
git add -A
git commit -m "Test: Crystal code generation produces output"
```

---

## Task 8: Fix Ruby-Specific Constructs in Generated Code

**Files:**
- Modify: `ragel/crystalcodegen.cpp`
- Modify: `ragel/crystaltable.cpp`

**Step 1: Identify Ruby-specific patterns in generated code**

Run: `cat /tmp/atoi1.cr | grep -E "(def |class |module |end|\$)" | head -20`

Common Ruby-Crystal differences to look for:
- Global variables (`$var`)
- Ruby-specific method names
- Type annotations needed

**Step 2: Search for Ruby-specific output patterns in code generators**

Run: `grep -n "def " ragel/crystaltable.cpp ragel/crystalcodegen.cpp | head -20`

**Step 3: Update code generators for Crystal compatibility**

Edit `ragel/crystaltable.cpp` and `ragel/crystalcodegen.cpp`:

Replace Ruby-specific output with Crystal-compatible code. Key changes:
- Ensure no Ruby global variables (Crystal doesn't use `$var`)
- Add type annotations where Crystal's inference needs help
- Fix any Ruby-isms in generated code

**Step 4: Rebuild Ragel**

Run: `make -j$(nproc)`
Expected: Build completes

**Step 5: Regenerate test output**

Run: `./ragel/ragel -Z -o /tmp/atoi1.cr test/atoi1.rl`

**Step 6: Inspect new output**

Run: `head -50 /tmp/atoi1.cr`

Look for remaining issues.

**Step 7: Commit**

```bash
git add ragel/crystalcodegen.cpp ragel/crystaltable.cpp
git commit -m "Fix Ruby-specific constructs for Crystal compatibility"
```

---

## Task 9: Test Generated Crystal Code Compiles

**Files:**
- Test: Generated `/tmp/atoi1.cr`

**Step 1: Try to compile generated Crystal code**

Run: `crystal build /tmp/atoi1.cr -o /tmp/atoi1 2>&1 | head -50`

Expected: Either compiles successfully or shows specific errors

**Step 2: Fix any Crystal compilation errors**

If there are errors:

1. Note the error messages
2. Edit `ragel/crystaltable.cpp` to fix the pattern
3. Rebuild: `make -j$(nproc)`
4. Regenerate: `./ragel/ragel -Z -o /tmp/atoi1.cr test/atoi1.rl`
5. Test compile again: `crystal build /tmp/atoi1.cr -o /tmp/atoi1`

Repeat until Crystal compilation succeeds.

**Step 3: Test the compiled Crystal program**

If compilation succeeds, run the program:

Run: `echo "12345" | /tmp/atoi1`
Expected: Program runs and outputs the parsed integer

**Step 4: Commit once compilation works**

```bash
git add ragel/crystaltable.cpp
git commit -m "Fix Crystal code generation to compile successfully"
```

---

## Task 10: Test with Additional Examples

**Files:**
- Test: `test/atoi2.rl`, `test/atoi3.rl`

**Step 1: Generate Crystal code for atoi2**

Run: `./ragel/ragel -Z -o /tmp/atoi2.cr test/atoi2.rl`

**Step 2: Compile and test atoi2**

Run:
```bash
crystal build /tmp/atoi2.cr -o /tmp/atoi2
echo "67890" | /tmp/atoi2
```

Expected: Works correctly

**Step 3: Generate and test atoi3**

Run:
```bash
./ragel/ragel -Z -o /tmp/atoi3.cr test/atoi3.rl
crystal build /tmp/atoi3.cr -o /tmp/atoi3
echo "-42" | /tmp/atoi3
```

Expected: Works correctly

**Step 4: Document any issues**

If any examples fail, note what needs fixing.

**Step 5: Commit after all tests pass**

```bash
git add -A
git commit -m "Test: Crystal code generation works for multiple examples"
```

---

## Task 11: Update Documentation

**Files:**
- Modify: `README`
- Modify: `CLAUDE.md`

**Step 1: Update README with Crystal support**

Edit `README`, add to list of supported languages:

```markdown
Ragel currently supports the following output languages:
- C
- D
- Java
- Ruby
- C#
- Go
- OCaml
- Crystal (table-style only)
```

**Step 2: Update CLAUDE.md**

Edit `CLAUDE.md`, add Crystal to the supported languages section:

Add to code generator list:
- **Crystal**: `crystalcodegen.cpp/h`
  - Styles: `crystaltable` (table-style only, more styles TBD)

**Step 3: Commit documentation**

```bash
git add README CLAUDE.md
git commit -m "docs: Add Crystal to supported languages"
```

---

## Task 12: Final Integration and Cleanup

**Files:**
- All modified files

**Step 1: Run full test suite for C (ensure no regressions)**

Run: `cd test && ./runtests -C 2>&1 | tail -20`

Expected: C tests still pass (no regressions from our changes)

**Step 2: Create a simple Crystal example**

Create `examples/crystal/atoi.cr`:

```crystal
# Simple atoi example for Crystal
# Generated by: ragel -Z atoi.rl

%%{
  machine atoi;
  write data;
}%%

def atoi(str : String) : Int32
  p = 0
  pe = str.length
  eof = str.length
  cs = atoi_start
  act = 0
  val = 0

  %%{
    action add_digit { val = val * 10 + (str[p].ord - 48) }
    action finish { return val }

    main := ( [0-9]+ $add_digit ) %finish;
    write init;
    write exec;
  }%%

  return -1
end

# Test
puts atoi(ARGV[0] || "0")
```

**Step 3: Generate and test the example**

Run:
```bash
./ragel/ragel -Z examples/crystal/atoi.rl -o /tmp/atoi_example.cr
crystal build /tmp/atoi_example.cr -o /tmp/atoi_example
/tmp/atoi_example 12345
```

Expected: Outputs "12345"

**Step 4: Final commit**

```bash
git add -A
git commit -m "feat: Add Crystal code generation support (table-style)

- Add Crystal code generator based on Ruby implementation
- Support table-style code generation for Crystal
- Add -Z command-line option for Crystal output
- Test with multiple examples
- Update documentation"
```

**Step 5: Tag the implementation**

Run:
```bash
git tag crystal-codegen-v1 -m "Crystal code generation initial implementation"
```

---

## Completion Criteria

Implementation is complete when:
- ✅ Crystal code generator files created and building
- ✅ `-Z` flag works and generates `.cr` files
- ✅ Generated Crystal code compiles with `crystal build`
- ✅ At least 3 test examples (atoi1, atoi2, atoi3) work correctly
- ✅ No regressions in existing C tests
- ✅ Documentation updated
- ✅ Code committed with clear commit messages

---

## Testing Checklist

- [ ] atoi1.rl generates valid Crystal code
- [ ] atoi2.rl generates valid Crystal code
- [ ] atoi3.rl generates valid Crystal code
- [ ] All generated files compile with Crystal compiler
- [ ] Compiled programs execute correctly
- [ ] C test suite still passes (no regressions)
- [ ] `-Z` flag recognized by ragel
- [ ] README and CLAUDE.md updated

---

## Notes for Developer

- Crystal and Ruby syntax are very similar - most code works as-is
- Focus on table-style generation first (simplest)
- Type inference in Crystal is good - rarely need explicit types
- Watch out for Ruby global variables (Crystal doesn't use them)
- Crystal is stricter about types than Ruby
- Generated code should be idiomatic Crystal, not just "Ruby that compiles"
- Test incrementally - don't wait until everything is done to build
- Commit frequently - each task should end with a commit
