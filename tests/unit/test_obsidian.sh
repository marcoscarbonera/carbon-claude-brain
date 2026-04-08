#!/usr/bin/env bash
# Unit tests for save_to_obsidian_journal(), save_learning(), save_error_solved()
LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../hooks/lib-carbon-brain.sh"

setup() {
  setup_temp_vault
  setup_temp_config
  write_minimal_env
  source "$LIB"
  load_config
}

teardown() {
  teardown_temp
}

test_save_to_obsidian_journal_creates_file() {
  run save_to_obsidian_journal "test-project" "2026-04-08" "10:00" "11:00" "## Sessão"
  assert_success
  assert_file_exists "$OBSIDIAN_VAULT/_claude-brain/global/journals/2026-04-08.md"
}

test_save_to_obsidian_journal_contains_project_name() {
  save_to_obsidian_journal "meu-projeto" "2026-04-08" "10:00" "11:00" "## Trabalho feito"
  content="$(cat "$OBSIDIAN_VAULT/_claude-brain/global/journals/2026-04-08.md")"
  assert_contains "$content" "meu-projeto"
}

test_save_to_obsidian_journal_appends_on_second_call() {
  save_to_obsidian_journal "proj-a" "2026-04-08" "09:00" "10:00" "## Sessão A"
  save_to_obsidian_journal "proj-b" "2026-04-08" "11:00" "12:00" "## Sessão B"
  content="$(cat "$OBSIDIAN_VAULT/_claude-brain/global/journals/2026-04-08.md")"
  assert_contains "$content" "proj-a"
  assert_contains "$content" "proj-b"
}

test_save_learning_adds_entry_to_existing_category() {
  printf "## Desenvolvimento\n- item existente\n" > "$OBSIDIAN_VAULT/_claude-brain/global/learnings.md"
  run save_learning "Desenvolvimento" "Novo aprendizado de teste"
  assert_success
  content="$(cat "$OBSIDIAN_VAULT/_claude-brain/global/learnings.md")"
  assert_contains "$content" "Novo aprendizado de teste"
}

test_save_error_solved_adds_entry() {
  # The function inserts before the first '---' line — file must have one
  printf "# Erros Resolvidos\n\n---\n\n---\n*footer*\n" \
    > "$OBSIDIAN_VAULT/_claude-brain/global/errors-solved.md"
  run save_error_solved "2026-04-08" "Erro Teste" "contexto" "msg de erro" "solução aplicada" "prevenção futura"
  assert_success
  content="$(cat "$OBSIDIAN_VAULT/_claude-brain/global/errors-solved.md")"
  assert_contains "$content" "Erro Teste"
  assert_contains "$content" "solução aplicada"
}

test_ensure_global_journal_dir_creates_missing_dir() {
  rm -rf "$OBSIDIAN_VAULT/_claude-brain/global/journals"
  run ensure_global_journal_dir
  assert_success
  [[ -d "$OBSIDIAN_VAULT/_claude-brain/global/journals" ]] || { fail "journals dir not created"; return 1; }
}
