#!/usr/bin/env bash
# Integration tests for hooks/post-tool-use.sh
HOOK="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../hooks/post-tool-use.sh"

setup() {
  setup_temp_vault
  setup_temp_config
  write_minimal_env
}

teardown() {
  teardown_temp
}

test_post_tool_use_logs_write_event() {
  run_piped '{"tool_name":"Write","tool_input":{"file_path":"/path/file.sh"}}' bash "$HOOK"
  assert_success
  assert_file_exists "$CARBON_BRAIN_DIR/activity.log"
  log="$(cat "$CARBON_BRAIN_DIR/activity.log")"
  assert_contains "$log" "Write"
}

test_post_tool_use_logs_edit_event() {
  run_piped '{"tool_name":"Edit","tool_input":{"file_path":"/path/file.sh"}}' bash "$HOOK"
  assert_success
  log="$(cat "$CARBON_BRAIN_DIR/activity.log")"
  assert_contains "$log" "Edit"
}

test_post_tool_use_logs_bash_event() {
  run_piped '{"tool_name":"Bash","tool_input":{"command":"ls"}}' bash "$HOOK"
  assert_success
  log="$(cat "$CARBON_BRAIN_DIR/activity.log")"
  assert_contains "$log" "Bash"
}

test_post_tool_use_does_not_log_read_event() {
  run_piped '{"tool_name":"Read","tool_input":{"file_path":"/path/file.sh"}}' bash "$HOOK"
  assert_success
  log="$(cat "$CARBON_BRAIN_DIR/activity.log" 2>/dev/null || echo "")"
  # Read should not appear in log
  if echo "$log" | grep -qE "\| Read \|"; then
    fail "Read event should not be logged"
    return 1
  fi
}

test_post_tool_use_never_blocks_on_invalid_json() {
  run_piped "not valid json at all" bash "$HOOK"
  assert_success
}

test_post_tool_use_rotates_log_when_large() {
  # Generate a large log (>10MB) using dd
  dd if=/dev/zero bs=1024 count=11000 2>/dev/null | tr '\0' 'x' \
    > "$CARBON_BRAIN_DIR/activity.log"
  run_piped '{"tool_name":"Write","tool_input":{"file_path":"/path/file.sh"}}' bash "$HOOK"
  assert_success
  line_count="$(wc -l < "$CARBON_BRAIN_DIR/activity.log")"
  [[ "$line_count" -le 1001 ]] || { fail "log not rotated: $line_count lines remain"; return 1; }
}
