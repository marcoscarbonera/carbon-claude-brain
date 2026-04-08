#!/usr/bin/env bash
# Unit tests for load_config() and get_config_dir()
# shellcheck disable=SC2154  # output/status set by run() in helpers.sh
LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../hooks/lib-carbon-brain.sh"

setup() {
  setup_temp_vault
  setup_temp_config
}

teardown() {
  teardown_temp
}

test_load_config_reads_obsidian_vault() {
  write_minimal_env
  # shellcheck source=/dev/null
  source "$LIB"
  load_config
  assert_contains "$OBSIDIAN_VAULT" "/vault"
}

test_load_config_reads_inkdrop_vars() {
  write_full_env
  # shellcheck source=/dev/null
  source "$LIB"
  load_config
  assert_contains "$INKDROP_URL" "localhost"
  assert_contains "$INKDROP_USER" "test@test.com"
}

test_load_config_fails_without_env() {
  # shellcheck source=/dev/null
  source "$LIB"
  run load_config
  assert_failure
}

test_load_config_migrates_legacy_config() {
  cat > "$CARBON_BRAIN_DIR/config" <<EOF
export OBSIDIAN_VAULT="$OBSIDIAN_VAULT"
EOF
  # shellcheck source=/dev/null
  source "$LIB"
  run load_config
  assert_success
}

test_get_config_dir_uses_plugin_data_when_set() {
  export CLAUDE_PLUGIN_DATA="$CARBON_BRAIN_DIR"
  # shellcheck source=/dev/null
  source "$LIB"
  result="$(get_config_dir)"
  assert_contains "$result" "$CARBON_BRAIN_DIR"
}

test_get_config_dir_falls_back_to_home() {
  unset CLAUDE_PLUGIN_DATA
  # shellcheck source=/dev/null
  source "$LIB"
  result="$(get_config_dir)"
  assert_contains "$result" ".carbon-brain"
}
