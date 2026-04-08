#!/usr/bin/env bash
# Tests for install.sh and lib-setup.sh functions
LIB_SETUP="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../lib-setup.sh"
INSTALL="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../install.sh"

setup() {
  setup_temp_vault
  setup_temp_config
}

teardown() {
  teardown_temp
}

test_validate_configuration_passes_with_valid_vault() {
  source "$LIB_SETUP"
  run validate_configuration "$OBSIDIAN_VAULT" "" "" ""
  assert_success
}

test_validate_configuration_fails_with_nonexistent_vault() {
  source "$LIB_SETUP"
  run validate_configuration "/nonexistent/vault/path" "" "" ""
  assert_failure
}

test_detect_obsidian_vaults_does_not_crash() {
  source "$LIB_SETUP"
  # Without Obsidian installed this may return nothing — but must not exit 127
  run detect_obsidian_vaults
  [[ "$status" -ne 127 ]] || { fail "command not found (exit 127)"; return 1; }
}

test_install_dry_run_creates_no_hooks() {
  # Snapshot hooks before
  before="$(find "${HOME}/.claude/hooks/" -name 'carbon-brain*' 2>/dev/null | sort || echo '')"
  # Run in dry-run with a pre-made .env (non-interactive)
  write_minimal_env
  cp "$CARBON_BRAIN_DIR/.env" "$(dirname "$INSTALL")/.env.test_tmp"
  run bash "$INSTALL" --dry-run < /dev/null
  after="$(find "${HOME}/.claude/hooks/" -name 'carbon-brain*' 2>/dev/null | sort || echo '')"
  rm -f "$(dirname "$INSTALL")/.env.test_tmp"
  [[ "$before" == "$after" ]] || { fail "dry-run created/removed hooks"; return 1; }
}

test_install_syntax_valid() {
  run bash -n "$INSTALL"
  assert_success
}

test_lib_setup_syntax_valid() {
  run bash -n "$LIB_SETUP"
  assert_success
}
