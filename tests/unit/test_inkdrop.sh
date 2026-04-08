#!/usr/bin/env bash
# Unit tests for is_inkdrop_enabled(), get_inkdrop_book_field(), save_to_inkdrop_journal()
# shellcheck disable=SC2154  # output/status set by run() in helpers.sh
LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../hooks/lib-carbon-brain.sh"

setup() {
  setup_temp_vault
  setup_temp_config
}

teardown() {
  teardown_temp
}

test_is_inkdrop_enabled_false_when_not_configured() {
  unset INKDROP_URL INKDROP_USER INKDROP_PASS
  # shellcheck source=/dev/null
  source "$LIB"
  run is_inkdrop_enabled
  assert_failure
}

test_is_inkdrop_enabled_true_when_all_vars_set() {
  export INKDROP_URL="http://localhost:19841"
  export INKDROP_USER="test@test.com"
  export INKDROP_PASS="testpass"
  # shellcheck source=/dev/null
  source "$LIB"
  run is_inkdrop_enabled
  assert_success
}

test_get_inkdrop_book_field_returns_field_when_set() {
  export INKDROP_NOTEBOOK_ID="book:abc123"
  # shellcheck source=/dev/null
  source "$LIB"
  result="$(get_inkdrop_book_field)"
  assert_contains "$result" "book:abc123"
}

test_get_inkdrop_book_field_empty_when_not_set() {
  unset INKDROP_NOTEBOOK_ID
  # shellcheck source=/dev/null
  source "$LIB"
  result="$(get_inkdrop_book_field)"
  [[ -z "$result" ]] || { fail "expected empty, got: $result"; return 1; }
}

test_save_to_inkdrop_journal_survives_curl_failure() {
  write_full_env
  # shellcheck source=/dev/null
  source "$LIB"
  load_config
  stub_curl_inkdrop_offline
  run save_to_inkdrop_journal "test-project" "2026-04-08" "10:00" "11:00" "## Sessão"
  # Inkdrop is optional — must not crash with exit 127 (command not found)
  [[ "$status" -ne 127 ]] || { fail "unexpected exit 127 (command not found)"; return 1; }
}

test_save_to_inkdrop_journal_skips_when_not_configured() {
  # No Inkdrop vars set — should succeed immediately (skip, not error)
  unset INKDROP_URL INKDROP_USER INKDROP_PASS
  # shellcheck source=/dev/null
  source "$LIB"
  run save_to_inkdrop_journal "test-project" "2026-04-08" "10:00" "11:00" "## Sessão"
  assert_success
}
