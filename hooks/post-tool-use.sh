#!/usr/bin/env bash
# carbon-claude-brain — post-tool-use.sh
# Captura uso de ferramentas importantes para log de atividade
# Recebe JSON do Claude Code via stdin

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

CONFIG_DIR=$(get_config_dir)
LOG_FILE="$CONFIG_DIR/activity.log"
LOG_MAX_SIZE_MB=10  # Rotacionar quando passar de 10MB

# ── Rotação de log se necessário ──────────────────────────────────────────

if [ -f "$LOG_FILE" ]; then
  LOG_SIZE_BYTES=$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)
  LOG_SIZE_MB=$((LOG_SIZE_BYTES / 1024 / 1024))

  if [ "$LOG_SIZE_MB" -ge "$LOG_MAX_SIZE_MB" ]; then
    # Rotacionar: arquivar log completo, manter últimas 1000 linhas
    TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
    cp "$LOG_FILE" "$CONFIG_DIR/activity_${TIMESTAMP}.log"
    tail -1000 "$LOG_FILE" > "$LOG_FILE.tmp"
    mv "$LOG_FILE.tmp" "$LOG_FILE"
  fi
fi

# ── Capturar tool usage ────────────────────────────────────────────────────

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | node -e "
  try {
    const d = JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));
    console.log(d.tool_name || '');
  } catch(e) {
    console.log('');
  }
" 2>/dev/null)

FILE_PATH=$(echo "$INPUT" | node -e "
  try {
    const d = JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));
    console.log(d.tool_input && d.tool_input.file_path ? d.tool_input.file_path : '');
  } catch(e) {
    console.log('');
  }
" 2>/dev/null)

# Registrar apenas ferramentas relevantes
TRACKED_TOOLS="Write|Edit|MultiEdit|Bash|TodoWrite"

if echo "$TOOL_NAME" | grep -qE "$TRACKED_TOOLS"; then
  echo "$(date '+%Y-%m-%d %H:%M') | $TOOL_NAME | $(pwd | xargs basename)" >> "$LOG_FILE"
fi

# ── Salvar planos no Obsidian ──────────────────────────────────────────────

PLANS_DIR="$HOME/.claude/plans"

if [[ "$TOOL_NAME" == "Write" || "$TOOL_NAME" == "Edit" ]] && \
   [[ "$FILE_PATH" == "$PLANS_DIR/"*.md ]]; then
  if [ -n "$OBSIDIAN_VAULT" ] && [ -d "$OBSIDIAN_VAULT" ]; then
    PROJECT_NAME="$(basename "$(pwd)")"
    DEST_DIR="$OBSIDIAN_VAULT/_claude-brain/projects/$PROJECT_NAME/plans"
    mkdir -p "$DEST_DIR"

    TODAY=$(date '+%Y-%m-%d')
    PLAN_BASENAME="$(basename "$FILE_PATH")"
    cp "$FILE_PATH" "$DEST_DIR/${TODAY}-${PLAN_BASENAME}" 2>/dev/null || true
  fi
fi

exit 0
