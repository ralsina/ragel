# Critical Bug Fix: Bytes vs String in Crystal Code Generator

**Date**: 2025-01-06
**Issue**: Incorrect use of `.ord` and `String` type
**Status**: ✅ **FIXED**

## Problem

The Crystal code generator was incorrectly using `.ord` on data access and using `String` type instead of byte-oriented types.

### Root Cause

Ragel operates on **bytes**, not characters. The code generator was:
1. Using `String` type (character-oriented)
2. Calling `.ord` on character access (redundant for bytes)
3. Incorrect assumption about Crystal's type system

### Original Generated Code (WRONG)

```crystal
def scan(data : String)
  _wide = data[p].ord  # WRONG: String indexing returns Char, .ord is redundant
  # ...
end
```

### Fixed Generated Code (CORRECT)

```crystal
def scan(data : Slice(UInt8))
  _wide = data[p]  # CORRECT: Slice indexing returns UInt8 directly
  # ...
end
```

## Changes Made

### 1. Code Generator Fix

**File**: `ragel/crystalcodegen.cpp`

**Line 310-314**: Removed `.ord` from data access

```cpp
// BEFORE (WRONG):
ret << DATA() << "[" << P() << "].ord";

// AFTER (CORRECT):
ret << DATA() << "[" << P() << "]";
```

**Rationale**: Ragel works on bytes. With `Slice(UInt8)` or `Bytes`, indexing already returns `UInt8` (0-255), which is already a numeric value. No `.ord` needed.

### 2. Example Updates

All examples updated to use `Slice(UInt8)` instead of `String`:

#### scanner.rl
```crystal
// BEFORE:
def scan(data : String)
  scan("a")  // String literal

// AFTER:
def scan(data : Slice(UInt8))
  scan("a".to_slice)  // Convert to Slice(UInt8)
```

#### atoi.rl
```crystal
// BEFORE:
def atoi(data : String) : Int64
  val = val * 10 + (data[p].ord - 48)  // Manual .ord in action

// AFTER:
def atoi(data : Slice(UInt8)) : Int64
  val = val * 10 + (data[p] - 48)  // Direct byte access
```

#### rpn.rl
```crystal
// BEFORE:
def rpn_eval(data : String)
  x = data[mark...p].to_i  // String slice

// AFTER:
def rpn_eval(data : Slice(UInt8))
  x = String.new(data[mark...p]).to_i  // Convert bytes to string
```

## Technical Details

### Type Comparison

| Operation | String | Slice(UInt8) | Bytes |
|-----------|--------|--------------|-------|
| Indexing `data[p]` | Returns `Char` | Returns `UInt8` | Returns `UInt8` |
| Numeric value | `data[p].ord` → `Int32` | `data[p]` → `UInt8` | `data[p]` → `UInt8` |
| Ragel compatibility | ❌ Wrong | ✅ Correct | ✅ Correct |
| Mutability | Immutable | Immutable | Mutable |

### Conversion Methods

```crystal
# String to bytes
"hello".to_slice  # Returns Slice(UInt8)
"hello".to_bytes  # Returns Bytes (mutable copy)

# Bytes to String
String.new(slice)  # Create String from Slice(UInt8)
String.new(bytes)  # Create String from Bytes
```

## Validation

### Test Results After Fix

All 3 examples × 4 styles = 12 combinations ✅ PASS

| Example | -T0 | -T1 | -F0 | -F1 |
|---------|-----|-----|-----|-----|
| atoi.rl | ✅ | ✅ | ✅ | ✅ |
| scanner.rl | ✅ | ✅ | ✅ | ✅ |
| rpn.rl | ✅ | ✅ | ✅ | ✅ |

**All tests pass with correct byte-oriented types!**

## Why This Matters

### Correctness
- Ragel operates on bytes (0-255)
- Using `String` with `Char` is semantically wrong
- `.ord` on bytes is redundant and causes errors

### Performance
- `Slice(UInt8)` is more efficient than `String`
- No need for `.ord` conversion overhead
- Direct byte access matches Ragel's byte-oriented design

### Compatibility
- Matches behavior of other Ragel targets (C, Go, etc.)
- Properly handles binary data
- Correct UTF-8 byte processing

## Migration Guide

If you have existing Crystal Ragel code using `String`:

### Before (Wrong)
```crystal
def parse(data : String)
  %%{
    write init;
    write exec;
  }%%
end

parse("hello")
```

### After (Correct)
```crystal
def parse(data : Slice(UInt8))
  %%{
    write init;
    write exec;
  }%%
end

parse("hello".to_slice)  # Convert string to bytes
```

### Actions Accessing Data

```crystal
# Before:
action get_byte { value = data[p].ord }

# After:
action get_byte { value = data[p] }  # Already UInt8
```

### Byte Slices to Strings

```crystal
# Extract bytes and convert to string
text = String.new(data[start...end])
```

## Conclusion

This was a **critical bug** that made the Crystal code generator semantically incorrect. The fix:

1. ✅ Removes incorrect `.ord` usage
2. ✅ Uses proper byte-oriented types
3. ✅ Matches Ragel's byte-oriented design
4. ✅ Maintains compatibility with all 4 code styles
5. ✅ All examples updated and tested

**The Crystal code generator now correctly works with bytes!**

---

**Last Updated**: 2025-01-06
**Impact**: Breaking change - requires updating existing code to use `Slice(UInt8)`
**Status**: Production-ready with correct types
