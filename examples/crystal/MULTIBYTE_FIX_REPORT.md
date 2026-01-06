# Bug Fix: Multi-byte Pattern Actions in Crystal Backend

**Date**: 2025-01-06
**Bug**: Ragel Crystal backend - Multi-byte UTF-8 patterns don't work
**Status**: ✅ **FIXED**

## Bug Report Summary

Multi-byte UTF-8 patterns (and other byte ranges with values > 127) didn't match correctly in the Crystal backend. Actions would fire on the wrong pattern and bytes wouldn't be consumed properly.

### Symptoms

1. **Wrong pattern matched**: 0xC3 (first byte of 2-byte UTF-8) matched 0x00..0x7F pattern when it shouldn't
2. **Incomplete consumption**: Only consumed 1 byte instead of 2
3. **trans_actions appeared broken**: All zeros in some cases

### Test Case

```ragel
utf8_2byte = 0xC2..0xDF 0x80..0xBF >match_2byte;
utf8_1byte = 0x00..0x7F >match_1byte;

main := utf8_2byte | utf8_1byte;
```

**Input**: `Bytes[0xC3, 0xB1]` (ñ in UTF-8)

**Before Fix**:
```
1byte matched: 195    # WRONG - matched 1-byte pattern
p=1, pe=2             # WRONG - only consumed 1 byte
```

**After Fix**:
```
2byte matched: ts=0, te=0  # CORRECT - matched 2-byte pattern
p=2, pe=2                   # CORRECT - consumed both bytes
```

## Root Cause Analysis

### The Problem

Ragel's transition tables contain **signed** Int8 values for range matching. For example:

```crystal
Utf8_test_trans_keys = [-128, -63, -62, -33, -32, -1, ...]
```

These represent byte ranges using signed integers (where -128 to -1 map to 128-255 in unsigned).

However, the Crystal code generator was using:

```crystal
data[p]  # Returns UInt8 (0-255)
```

When Crystal compares `UInt8` with `Int8`:
```crystal
if data[p] < Utf8_test_trans_keys[_mid]
```

It promotes both to a common type, **breaking the signed comparison**.

### Example of the Bug

For input `0xC3` (195 decimal):

**Expected behavior** (as signed int8):
- 0xC3 interpreted as signed: -61
- Range check: -62 ≤ -61 ≤ -33 → **MATCH** (second range)

**Actual behavior** (with UInt8):
- 0xC3 stays as unsigned: 195
- Comparison: `195 < -63` → **false** (195 is treated as large positive)
- Comparison: `195 > -33` → **true**
- Binary search fails to find correct range → **WRONG PATTERN MATCHED**

### Why Ruby Works

Ruby uses `.ord` which returns an `Integer` that naturally handles signed values through pack/unpack semantics:

```ruby
data[p].ord  # Returns Integer with proper signed comparison
```

## The Fix

### Solution: Sign-Extension

Convert UInt8 to signed Int32 using bit-twiddling to preserve the signed interpretation:

```cpp
// In crystalcodegen.cpp, GET_KEY() function:
ret << "((" << DATA() << "[" << P() << "].to_i32 << 24) >> 24)";
```

This generates:
```crystal
if ((data[p].to_i32 << 24) >> 24) < Utf8_test_trans_keys[_mid]
```

### How It Works

The bit-twiddling `(x << 24) >> 24` **sign-extends** the byte:

1. Convert UInt8 to Int32: `195_u8 → 195_i32`
2. Shift left by 24 bits: `195 → 0xC3000000` (moves byte to high position)
3. Arithmetic shift right by 24 bits: `0xC3000000 → -61` (sign-extends)

**Example**:
```
Input: 0xC3 (195)
Step 1: 195_u8.to_i32 = 195
Step 2: 195 << 24 = 3271557120 (0xC3000000)
Step 3: 3271557120 >> 24 = -61 (sign-extended)
Result: -61 (correct signed interpretation!)
```

## Code Changes

### File: `ragel/crystalcodegen.cpp`

**Line 310-316**: Fixed GET_KEY() method

```cpp
// BEFORE (BROKEN):
ret << DATA() << "[" << P() << "]";  // UInt8 comparison breaks ranges

// AFTER (FIXED):
ret << "((" << DATA() << "[" << P() << "].to_i32 << 24) >> 24)";
```

## Validation

### Test Results

All tests pass with the fix:

| Example | -T0 | -T1 | -F0 | -F1 |
|---------|-----|-----|-----|-----|
| **utf8_test.rl** | ✅ | ✅ | ✅ | ✅ |
| **atoi.rl** | ✅ | ✅ | ✅ | ✅ |
| **scanner.rl** | ✅ | ✅ | ✅ | ✅ |
| **rpn.rl** | ✅ | ✅ | ✅ | ✅ |

### utf8_test.rl Output

```bash
$ ./utf8_test
2byte matched: ts=0, te=0
p=2, pe=2
```

✅ Correct pattern matched (2-byte)
✅ All bytes consumed (p=2)
✅ No overflow or comparison errors

### Compatibility

- ✅ All existing examples still work
- ✅ All 4 code styles (-T0, -T1, -F0, -F1) work correctly
- ✅ No performance degradation (bit operations are fast)
- ✅ No breaking API changes

## Technical Details

### Why Not Other Approaches?

**Attempted 1**: Cast to Int8
```crystal
data[p].to_i8  # OVERFLOW for values > 127
```
Rejected: Crystal raises overflow error for 195.to_i8

**Attempted 2**: Cast to Int32
```crystal
data[p].to_i32  # Wrong: 195_u8.to_i32 = 195 (not -61)
```
Rejected: Converts value but doesn't sign-extend

**Attempted 3**: Manual adjustment
```crystal
data[p].to_i32 >= 128 ? data[p].to_i32 - 256 : data[p].to_i32
```
Rejected: Verbose and generates inefficient code

**Final**: Bit-twiddling sign-extension
```crystal
(data[p].to_i32 << 24) >> 24
```
✅ Accepted: Clean, efficient, correct

## Impact

This fix enables Crystal Ragel code generation to work correctly for:

- ✅ UTF-8 parsers (multi-byte sequences)
- ✅ Binary protocols with values > 127
- ✅ Complex grammars with alternations
- ✅ Any byte-based pattern matching

## Migration Notes

**No code changes required** for existing Crystal Ragel programs. The fix is in the code generator only.

Simply rebuild your Ragel files:
```bash
ragel -Y -o output.cr input.rl
crystal build output.cr
```

## References

- **Bug discovered by**: User bug report (2025-01-06)
- **Root cause analysis**: Systematic debugging methodology
- **Fix validated on**: Crystal 1.13.2, Ragel 7.0.4.11
- **Test files**: `examples/crystal/utf8_test.rl`

---

**Last Updated**: 2025-01-06
**Status**: Production-ready ✅
**Backward Compatible**: Yes ✅
