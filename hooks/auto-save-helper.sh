#!/usr/bin/env bash
# carbon-claude-brain — auto-save-helper.sh
# Helper executado por hooks agent para salvar resumo da sessão

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib-carbon-brain.sh"

# Carregar configuração
if ! load_config; then
  echo "❌ Erro: configuração não encontrada"
  exit 1
fi

# Argumentos: PROJECT_NAME DATE START_TIME END_TIME SUMMARY_CONTENT
PROJECT_NAME="$1"
DATE="$2"
START_TIME="$3"
END_TIME="$4"
SUMMARY_FILE="$5"

if [ -z "$PROJECT_NAME" ] || [ -z "$DATE" ] || [ -z "$SUMMARY_FILE" ]; then
  echo "❌ Uso: auto-save-helper.sh PROJECT DATE START_TIME END_TIME SUMMARY_FILE"
  exit 1
fi

# Ler conteúdo do resumo
if [ ! -f "$SUMMARY_FILE" ]; then
  echo "❌ Arquivo de resumo não encontrado: $SUMMARY_FILE"
  exit 1
fi

CONTENT=$(cat "$SUMMARY_FILE")

# Salvar no Obsidian (SEMPRE)
if save_to_obsidian_journal "$PROJECT_NAME" "$DATE" "$START_TIME" "$END_TIME" "$CONTENT"; then
  echo "✅ Salvo no Obsidian: _claude-brain/global/journals/$DATE.md"
else
  echo "❌ Erro ao salvar no Obsidian"
  exit 1
fi

# Salvar no Inkdrop (SE HABILITADO)
if is_inkdrop_enabled; then
  if save_to_inkdrop_journal "$PROJECT_NAME" "$DATE" "$START_TIME" "$END_TIME" "$CONTENT"; then
    echo "✅ Salvo no Inkdrop: Journal $PROJECT_NAME — $DATE"
  else
    echo "⚠️  Inkdrop indisponível (salvo apenas no Obsidian)"
  fi
else
  echo "ℹ️  Inkdrop desabilitado (salvo apenas no Obsidian)"
fi

# Limpar arquivo temporário
rm -f "$SUMMARY_FILE"

exit 0
