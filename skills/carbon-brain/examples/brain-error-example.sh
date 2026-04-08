#!/usr/bin/env bash
# Exemplo de uso do /brain-error
# Documenta erro resolvido em global/errors-solved.md

# shellcheck source=/dev/null
source ~/.claude/hooks/lib-carbon-brain.sh
load_config

DATE="$(date '+%Y-%m-%d')"

if save_error_solved \
  "$DATE" \
  "NullPointerException ao acessar user.profile" \
  "Fazendo update de perfil do usuário" \
  "Cannot read property 'name' of null" \
  "Adicionar verificação: if (user.profile) antes de acessar" \
  "Sempre validar que objetos nested existem antes de acessar propriedades"; then
  echo "✅ Erro documentado em global/errors-solved.md"
else
  echo "❌ Erro ao documentar"
fi
