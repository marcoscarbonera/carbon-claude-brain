#!/usr/bin/env bash
# carbon-claude-brain — lib-carbon-brain.sh
# Funções helper compartilhadas entre hooks

# Carrega configuração de .env (ou config antigo para compatibilidade)
load_config() {
  local ENV_FILE="$HOME/.carbon-brain/.env"
  local OLD_CONFIG="$HOME/.carbon-brain/config"

  # Preferir .env (novo)
  if [ -f "$ENV_FILE" ]; then
    # Carregar .env (exportar variáveis)
    set -a
    source "$ENV_FILE"
    set +a
    return 0
  # Fallback para config antigo
  elif [ -f "$OLD_CONFIG" ]; then
    source "$OLD_CONFIG"
    return 0
  else
    return 1
  fi
}

# Loga erro
log_error() {
  local ERROR_LOG="$HOME/.carbon-brain/errors.log"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$ERROR_LOG"
}
