#!/usr/bin/env bash
# carbon-claude-brain — session-end.sh
# Sinaliza ao Claude para salvar resumo da sessão

# ── Carregar biblioteca e configuração ─────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib-carbon-brain.sh"

# Carregar configuração (.env ou config antigo)
if ! load_config; then
  exit 0
fi

PROJECT_NAME="$(basename "$(pwd)")"
TODAY=$(date '+%Y-%m-%d')
NOW=$(date '+%H:%M')

# Criar arquivo de trigger — o Claude vai ler isso via skill
# e executar o salvamento no Obsidian e Inkdrop
TRIGGER_FILE="$HOME/.carbon-brain/session-end-trigger.json"

cat > "$TRIGGER_FILE" <<EOF
{
  "project": "$PROJECT_NAME",
  "date": "$TODAY",
  "time": "$NOW",
  "obsidian_vault": "$OBSIDIAN_VAULT",
  "inkdrop_url": "$INKDROP_URL",
  "action": "save_session_summary"
}
EOF

echo ""
echo "🧠 carbon-claude-brain: sessão encerrada. Salve o resumo com /brain-save"
echo ""
