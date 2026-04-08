#!/usr/bin/env bash
# carbon-claude-brain test runner — zero external dependencies
#
# Usage:
#   ./tests/run_tests.sh           # run all tests
#   ./tests/run_tests.sh unit      # filter by path substring
#   ./tests/run_tests.sh unit/test_config  # run specific file

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HELPERS="$TESTS_DIR/helpers.sh"

PASS=0
FAIL=0
FAIL_LIST=()

# Run a single test function from a file in an isolated subprocess
_run_single_test() {
  local file="$1"
  local fn="$2"
  bash -c "
    set -eo pipefail
    source '$HELPERS'
    source '$file'
    type setup &>/dev/null && setup
    rc=0
    $fn || rc=\$?
    type teardown &>/dev/null && teardown 2>/dev/null || true
    exit \$rc
  " </dev/null 2>&1
}

# Discover and run all test_* functions in a file
run_test_file() {
  local file="$1"
  local rel="${file#$TESTS_DIR/}"
  echo ""
  echo "=== $rel ==="

  local fns
  fns="$(grep -E '^test_[a-zA-Z0-9_]+\(\)' "$file" | sed 's/().*//')"

  if [[ -z "$fns" ]]; then
    echo "  (no tests found)"
    return
  fi

  while IFS= read -r fn; do
    [[ -z "$fn" ]] && continue
    local label="${fn#test_}"
    local err_msg
    if err_msg="$(_run_single_test "$file" "$fn")"; then
      echo "  ✓ $label"
      ((PASS++)) || true
    else
      echo "  ✗ $label"
      # Print indented error lines
      while IFS= read -r line; do
        echo "      $line"
      done <<< "$err_msg"
      ((FAIL++)) || true
      FAIL_LIST+=("$rel::$fn")
    fi
  done <<< "$fns"
}

# ── Entry point ────────────────────────────────────────────────────────────────

FILTER="${1:-}"

while IFS= read -r -d '' file; do
  [[ -n "$FILTER" && "$file" != *"$FILTER"* ]] && continue
  run_test_file "$file"
done < <(find "$TESTS_DIR" -name 'test_*.sh' -not -path '*/bats/*' -print0 | sort -z)

echo ""
echo "────────────────────────────────────"
echo "RESULTS: $PASS passed, $FAIL failed"

if [[ "$FAIL" -gt 0 ]]; then
  echo ""
  echo "Failed tests:"
  for t in "${FAIL_LIST[@]}"; do
    echo "  - $t"
  done
  exit 1
fi
