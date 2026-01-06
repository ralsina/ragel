#!/bin/bash
# Comprehensive test script for Crystal Ragel examples
# Tests all working code styles

set -e

# Find ragel binary
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RAGEL="$SCRIPT_DIR/../../ragel/ragel"
if [ ! -f "$RAGEL" ]; then
  RAGEL="ragel"
fi

echo "=== Crystal Ragel - Comprehensive Test Suite ==="
echo "Using: $RAGEL"
echo

# Test table styles
echo "=== Testing Table-Style (-T0, -T1) ==="
echo

echo "1. atoi.rl with -T0 (standard table)"
$RAGEL -T0 -Y -o atoi.cr atoi.rl
crystal build atoi.cr -o atoi
RESULT=$(echo "-42" | ./atoi)
[ "$RESULT" = "-42" ] && echo "   ✅ PASSED" || exit 1

echo "2. atoi.rl with -T1 (fast table)"
$RAGEL -T1 -Y -o atoi.cr atoi.rl
crystal build atoi.cr -o atoi
RESULT=$(echo "99" | ./atoi)
[ "$RESULT" = "99" ] && echo "   ✅ PASSED" || exit 1

echo "3. rpn.rl with -T0 (standard table)"
$RAGEL -T0 -Y -o rpn.cr rpn.rl
crystal build rpn.cr -o rpn
COUNT=$(./rpn 2>&1 | grep -c "SUCCESS")
[ "$COUNT" = "13" ] && echo "   ✅ PASSED (13/13 tests)" || exit 1

echo "4. rpn.rl with -T1 (fast table)"
$RAGEL -T1 -Y -o rpn.cr rpn.rl
crystal build rpn.cr -o rpn
COUNT=$(./rpn 2>&1 | grep -c "SUCCESS")
[ "$COUNT" = "13" ] && echo "   ✅ PASSED (13/13 tests)" || exit 1

echo
echo "=== Testing Flat-Style (-F0, -F1) ==="
echo

echo "5. atoi.rl with -F0 (standard flat)"
$RAGEL -F0 -Y -o atoi.cr atoi.rl
crystal build atoi.cr -o atoi
RESULT=$(echo "-42" | ./atoi)
[ "$RESULT" = "-42" ] && echo "   ✅ PASSED" || exit 1

echo "6. atoi.rl with -F1 (fast flat)"
$RAGEL -F1 -Y -o atoi.cr atoi.rl
crystal build atoi.cr -o atoi
RESULT=$(echo "99" | ./atoi)
[ "$RESULT" = "99" ] && echo "   ✅ PASSED" || exit 1

echo "7. rpn.rl with -F0 (standard flat)"
$RAGEL -F0 -Y -o rpn.cr rpn.rl
crystal build rpn.cr -o rpn
COUNT=$(./rpn 2>&1 | grep -c "SUCCESS")
[ "$COUNT" = "13" ] && echo "   ✅ PASSED (13/13 tests)" || exit 1

echo "8. rpn.rl with -F1 (fast flat)"
$RAGEL -F1 -Y -o rpn.cr rpn.rl
crystal build rpn.cr -o rpn
COUNT=$(./rpn 2>&1 | grep -c "SUCCESS")
[ "$COUNT" = "13" ] && echo "   ✅ PASSED (13/13 tests)" || exit 1

echo
echo "=== All Tests Passed! ==="
echo
echo "Summary:"
echo "  Table-Style (-T0): ✅ Working"
echo "  Table-Style (-T1): ✅ Working"
echo "  Flat-Style (-F0):  ✅ Working"
echo "  Flat-Style (-F1):  ✅ Working"
echo
echo "Clean up:"
echo "  rm -f atoi.cr atoi rpn.cr rpn"
