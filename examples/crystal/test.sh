#!/bin/bash
# Test script for Crystal Ragel examples
# Tests both atoi and rpn with standard and fast table styles

set -e

# Find ragel binary - use local build if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RAGEL="$SCRIPT_DIR/../../ragel/ragel"
if [ ! -f "$RAGEL" ]; then
  RAGEL="ragel"
fi

echo "=== Testing Crystal Ragel Code Generation ==="
echo "Using: $RAGEL"
echo

# Test atoi
echo "Testing atoi.rl..."
$RAGEL -T0 -Y -o atoi.cr atoi.rl
crystal build atoi.cr -o atoi
RESULT=$(echo "-42" | ./atoi)
if [ "$RESULT" = "-42" ]; then
  echo "  ✅ atoi (-T0): PASSED"
else
  echo "  ❌ atoi (-T0): FAILED (got $RESULT, expected -42)"
  exit 1
fi

$RAGEL -T1 -Y -o atoi.cr atoi.rl
crystal build atoi.cr -o atoi
RESULT=$(echo "99" | ./atoi)
if [ "$RESULT" = "99" ]; then
  echo "  ✅ atoi (-T1): PASSED"
else
  echo "  ❌ atoi (-T1): FAILED (got $RESULT, expected 99)"
  exit 1
fi

# Test rpn
echo
echo "Testing rpn.rl..."
$RAGEL -T0 -Y -o rpn.cr rpn.rl
crystal build rpn.cr -o rpn
if ./rpn > /dev/null 2>&1; then
  echo "  ✅ rpn (-T0): PASSED (13/13 tests)"
else
  echo "  ❌ rpn (-T0): FAILED"
  exit 1
fi

$RAGEL -T1 -Y -o rpn.cr rpn.rl
crystal build rpn.cr -o rpn
if ./rpn > /dev/null 2>&1; then
  echo "  ✅ rpn (-T1): PASSED (13/13 tests)"
else
  echo "  ❌ rpn (-T1): FAILED"
  exit 1
fi

echo
echo "=== All Tests Passed! ==="
echo
echo "Crystal code generation is working correctly:"
echo "  ✅ Standard table-style (-T0)"
echo "  ✅ Fast table-style (-T1)"
echo
echo "Clean up:"
echo "  rm -f atoi.cr atoi rpn.cr rpn"
