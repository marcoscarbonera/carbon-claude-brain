#!/usr/bin/env bash
# Integration tests for hooks/session-end.sh
# shellcheck disable=SC2154  # output/status set by run() in helpers.sh
HOOK="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../hooks/session-end.sh"

setup() {
  setup_temp_vault
  setup_temp_config
  write_minimal_env
  # Seed activity.log with some actions for today
  cat > "$CARBON_BRAIN_DIR/activity.log" <<EOF
$(date '+%Y-%m-%d') 10:00 | Write | test-project
$(date '+%Y-%m-%d') 10:05 | Edit | test-project
$(date '+%Y-%m-%d') 10:10 | Bash | test-project
EOF
}

teardown() {
  teardown_temp
}

test_session_end_creates_journal_file() {
  run bash "$HOOK"
  assert_success
  today="$(date +%Y-%m-%d)"
  assert_file_exists "$OBSIDIAN_VAULT/_claude-brain/global/journals/${today}.md"
}

test_session_end_journal_contains_project_name() {
  bash "$HOOK"
  today="$(date +%Y-%m-%d)"
  content="$(cat "$OBSIDIAN_VAULT/_claude-brain/global/journals/${today}.md")"
  # PROJECT_NAME is basename of pwd (e.g. carbon-claude-brain)
  proj="$(basename "$(pwd)")"
  assert_contains "$content" "$proj"
}

test_session_end_appends_second_session_same_day() {
  bash "$HOOK"
  bash "$HOOK"
  today="$(date +%Y-%m-%d)"
  # Should have at least 2 "Session" headers
  count="$(grep -c "^## Session" "$OBSIDIAN_VAULT/_claude-brain/global/journals/${today}.md" || echo 0)"
  [[ "$count" -ge 2 ]] || { fail "expected >=2 session headers, got $count"; return 1; }
}

test_session_end_fails_if_vault_inaccessible() {
  # Overwrite .env to point to nonexistent vault
  printf 'OBSIDIAN_VAULT="/nonexistent/vault/path"\n' > "$CARBON_BRAIN_DIR/.env"
  run bash "$HOOK"
  assert_failure
}

test_session_end_succeeds_without_inkdrop() {
  # .env has no Inkdrop vars — should save to Obsidian only
  run bash "$HOOK"
  assert_success
}

test_session_end_succeeds_when_inkdrop_offline() {
  write_full_env
  stub_curl_inkdrop_offline
  run bash "$HOOK"
  # Inkdrop failure must not block the Obsidian save
  assert_success
  today="$(date +%Y-%m-%d)"
  assert_file_exists "$OBSIDIAN_VAULT/_claude-brain/global/journals/${today}.md"
}
