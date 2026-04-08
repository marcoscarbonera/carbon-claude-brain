#!/usr/bin/env bash
# Integration tests for hooks/session-start.sh
HOOK="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../hooks/session-start.sh"
HOOK_DIR="$(dirname "$HOOK")"

setup() {
  setup_temp_vault
  setup_temp_config
  write_minimal_env
  # Seed vault with content for context loading
  printf "## Desenvolvimento\n- Aprendizado de teste\n" \
    > "$OBSIDIAN_VAULT/_claude-brain/global/learnings.md"
  printf "## 2026-01-01 — Erro\n- Solução: corrigido\n" \
    > "$OBSIDIAN_VAULT/_claude-brain/global/errors-solved.md"
  # session-start.sh uses basename "$(pwd)" as project name
  local proj_name
  proj_name="$(basename "$(pwd)")"
  mkdir -p "$OBSIDIAN_VAULT/_claude-brain/projects/$proj_name"
  printf "# Contexto\n- Stack: bash\n" \
    > "$OBSIDIAN_VAULT/_claude-brain/projects/$proj_name/project-context.md"
}

teardown() {
  teardown_temp
}

test_session_start_injects_learnings() {
  # CLAUDE_PLUGIN_DATA tells the hook where to find the .env
  run bash "$HOOK"
  assert_output "Aprendizado de teste"
}

test_session_start_injects_project_context() {
  run bash "$HOOK"
  assert_output "Stack: bash"
}

test_session_start_respects_skip_flag() {
  run env CARBON_BRAIN_SKIP=1 bash "$HOOK"
  assert_success
  assert_not_output "Aprendizado de teste"
}

test_session_start_exits_zero_without_env_file() {
  rm -f "$CARBON_BRAIN_DIR/.env"
  run bash "$HOOK"
  # load_config fails → hook exits 0 (graceful skip)
  assert_success
}

test_session_start_succeeds_without_inkdrop() {
  # .env has no Inkdrop vars — must succeed
  run bash "$HOOK"
  assert_success
}

test_session_start_loads_obsidian_context_when_inkdrop_offline() {
  write_full_env
  stub_curl_inkdrop_offline
  run bash "$HOOK"
  # Inkdrop offline must not prevent Obsidian context from loading
  assert_output "Aprendizado de teste"
}
