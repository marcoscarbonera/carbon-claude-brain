#!/usr/bin/env bash
# carbon-claude-brain — session-end.sh
# Salva automaticamente resumo da sessão no Obsidian e Inkdrop

# ── Carregar biblioteca e configuração ─────────────────────────────────────

# Usar CLAUDE_PLUGIN_ROOT se disponível (modo marketplace), senão fallback para SCRIPT_DIR
if [ -n "$CLAUDE_PLUGIN_ROOT" ]; then
  source "$CLAUDE_PLUGIN_ROOT/hooks/lib-carbon-brain.sh"
else
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/lib-carbon-brain.sh"
fi

# Carregar configuração (.env ou config antigo)
if ! load_config; then
  exit 0
fi

PROJECT_NAME="$(basename "$(pwd)")"
TODAY=$(date '+%Y-%m-%d')
END_TIME=$(date '+%H:%M')
CONFIG_DIR=$(get_config_dir)

# ── Detectar horário de início da sessão ──────────────────────────────────

# Tentar pegar do activity.log
ACTIVITY_LOG="$CONFIG_DIR/activity.log"
START_TIME="--:--"

if [ -f "$ACTIVITY_LOG" ]; then
  # Pegar primeiro registro de hoje
  FIRST_ACTIVITY=$(grep "^$TODAY" "$ACTIVITY_LOG" | head -1 | cut -d'|' -f1 | awk '{print $2}')
  if [ -n "$FIRST_ACTIVITY" ]; then
    START_TIME="$FIRST_ACTIVITY"
  fi
fi

# ── Gerar resumo automático da sessão ──────────────────────────────────────

# Coletar atividades do log
ACTIVITY_SUMMARY=""
if [ -f "$ACTIVITY_LOG" ]; then
  # Contar ações por ferramenta
  WRITE_COUNT=$(grep "^$TODAY" "$ACTIVITY_LOG" | grep -c "Write" || echo "0")
  EDIT_COUNT=$(grep "^$TODAY" "$ACTIVITY_LOG" | grep -c "Edit" || echo "0")
  BASH_COUNT=$(grep "^$TODAY" "$ACTIVITY_LOG" | grep -c "Bash" || echo "0")

  if [ "$WRITE_COUNT" -gt 0 ] || [ "$EDIT_COUNT" -gt 0 ] || [ "$BASH_COUNT" -gt 0 ]; then
    ACTIVITY_SUMMARY="### Atividades da sessão
- Arquivos criados: $WRITE_COUNT
- Arquivos editados: $EDIT_COUNT
- Comandos executados: $BASH_COUNT
"
  fi
fi

# Criar conteúdo do resumo
CONTENT="### Sessão de trabalho

$ACTIVITY_SUMMARY
> *Resumo gerado automaticamente. Use \`/carbon-brain-save\` para criar resumos detalhados.*"

# ── Salvar no Obsidian (SEMPRE) ───────────────────────────────────────────

if save_to_obsidian_journal "$PROJECT_NAME" "$TODAY" "$START_TIME" "$END_TIME" "$CONTENT"; then
  echo ""
  echo "✅ Sessão salva: _claude-brain/global/journals/$TODAY.md"
else
  log_error "session-end: Falha ao salvar no Obsidian"
  echo ""
  echo "❌ Erro ao salvar sessão no Obsidian (verifique ~/.carbon-brain/errors.log)"
  exit 1
fi

# ── Salvar no Inkdrop (SE HABILITADO) ─────────────────────────────────────

if is_inkdrop_enabled; then
  if save_to_inkdrop_journal "$PROJECT_NAME" "$TODAY" "$START_TIME" "$END_TIME" "$CONTENT"; then
    echo "✅ Sessão salva no Inkdrop"
  else
    log_error "session-end: Falha ao salvar no Inkdrop"
    echo "⚠️  Inkdrop indisponível (salvo apenas no Obsidian)"
  fi
fi

echo ""
