#!/usr/bin/env bash
# Shared helpers for all tests — framework functions + setup/teardown utilities
# Sourced by each test subprocess before running a test function

# ── Framework: assert_*, run(), fail() ────────────────────────────────────────

# These variables are set by run() and read by assert_*
output=""
status=0

# Run a command, capture its output in $output and exit code in $status
run() {
  set +e
  output="$("$@" 2>&1)"
  status=$?
  set -e
}

# Pipe stdin through a command, capture output/$status
run_piped() {
  local input="$1"; shift
  set +e
  output="$(echo "$input" | "$@" 2>&1)"
  status=$?
  set -e
}

fail() {
  printf "FAIL: %b\n" "$*" >&2
  return 1
}

assert_success() {
  if [[ "$status" -ne 0 ]]; then
    fail "expected exit 0, got $status\noutput: $output"
    return 1
  fi
}

assert_failure() {
  if [[ "$status" -eq 0 ]]; then
    fail "expected non-zero exit, got 0\noutput: $output"
    return 1
  fi
}

assert_output() {
  local expected="$1"
  if ! echo "$output" | grep -qF "$expected"; then
    fail "expected output to contain: $expected\nactual: $output"
    return 1
  fi
}

assert_not_output() {
  local unexpected="$1"
  if echo "$output" | grep -qF "$unexpected"; then
    fail "expected output NOT to contain: $unexpected\nactual: $output"
    return 1
  fi
}

assert_file_exists() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    fail "expected file to exist: $path"
    return 1
  fi
}

assert_file_not_exists() {
  local path="$1"
  if [[ -f "$path" ]]; then
    fail "expected file NOT to exist: $path"
    return 1
  fi
}

assert_contains() {
  local haystack="$1" needle="$2"
  if ! echo "$haystack" | grep -qF "$needle"; then
    fail "expected string to contain: $needle\nactual: $haystack"
    return 1
  fi
}

# ── Setup/teardown utilities ───────────────────────────────────────────────────

setup_temp_vault() {
  export TEST_TEMP_DIR
  TEST_TEMP_DIR="$(mktemp -d)"
  export OBSIDIAN_VAULT="$TEST_TEMP_DIR/vault"
  mkdir -p "$OBSIDIAN_VAULT/_claude-brain/global/journals"
  touch "$OBSIDIAN_VAULT/_claude-brain/global/learnings.md"
  touch "$OBSIDIAN_VAULT/_claude-brain/global/errors-solved.md"
  touch "$OBSIDIAN_VAULT/_claude-brain/global/patterns.md"
  mkdir -p "$OBSIDIAN_VAULT/_claude-brain/projects/test-project"
}

setup_temp_config() {
  export CARBON_BRAIN_DIR="$TEST_TEMP_DIR/carbon-brain"
  export CLAUDE_PLUGIN_DATA="$CARBON_BRAIN_DIR"
  mkdir -p "$CARBON_BRAIN_DIR"
}

write_minimal_env() {
  cat > "$CARBON_BRAIN_DIR/.env" <<EOF
OBSIDIAN_VAULT="$OBSIDIAN_VAULT"
EOF
}

write_full_env() {
  cat > "$CARBON_BRAIN_DIR/.env" <<EOF
OBSIDIAN_VAULT="$OBSIDIAN_VAULT"
INKDROP_URL="http://localhost:19841"
INKDROP_USER="test@test.com"
INKDROP_PASS="testpass"
INKDROP_NOTEBOOK_ID="book:test123"
EOF
}

# Stub curl to return empty Inkdrop response (no notes found)
stub_curl_inkdrop_empty() {
  curl() {
    echo '{"items":[],"totalRows":0}'
    return 0
  }
  export -f curl
}

# Stub curl to simulate Inkdrop offline (connection refused)
stub_curl_inkdrop_offline() {
  curl() {
    return 7
  }
  export -f curl
}

# Stub curl to simulate successful note creation
stub_curl_inkdrop_create() {
  curl() {
    echo '{"_id":"note:mock0001","title":"test"}'
    return 0
  }
  export -f curl
}

teardown_temp() {
  [[ -n "${TEST_TEMP_DIR:-}" ]] && rm -rf "$TEST_TEMP_DIR"
  unset TEST_TEMP_DIR OBSIDIAN_VAULT CARBON_BRAIN_DIR CLAUDE_PLUGIN_DATA
  unset -f curl 2>/dev/null || true
}
