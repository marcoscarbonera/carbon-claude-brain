#!/usr/bin/env bash
# Exemplo de uso do /brain-learn
# Salva aprendizado reutilizável em global/learnings.md

source ~/.claude/hooks/lib-carbon-brain.sh
load_config

# Salvar aprendizado na categoria certa
if save_learning "Performance" "Sempre adicionar índice em colunas usadas em WHERE/JOIN"; then
  echo "✅ Aprendizado salvo em global/learnings.md"
else
  echo "❌ Erro ao salvar aprendizado"
fi

# Categorias disponíveis:
# - Desenvolvimento
# - Arquitetura
# - Performance
# - Segurança
# - Testing
# - DevOps
