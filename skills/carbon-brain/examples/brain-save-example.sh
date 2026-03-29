#!/usr/bin/env bash
# Exemplo de uso do /brain-save
# Salva resumo da sessão em Obsidian + Inkdrop

# Carregar biblioteca
source ~/.claude/hooks/lib-carbon-brain.sh

# Carregar configuração (.env ou config antigo)
load_config

# Obter variáveis
PROJECT="$(basename "$(pwd)")"
DATE="$(date '+%Y-%m-%d')"
START_TIME="14:30"  # Pegar do trigger file
END_TIME="$(date '+%H:%M')"

# Preparar conteúdo
CONTENT="### O que foi feito
- Implementei feature X
- Corrigi bug Y

### Erros e aprendizados
- Erro: timeout na API
  Solução: aumentei timeout para 5s

### Próximos passos
- [ ] Adicionar testes
- [ ] Deploy em staging"

# 1. Salvar no Obsidian (SEMPRE)
if save_to_obsidian_journal "$PROJECT" "$DATE" "$START_TIME" "$END_TIME" "$CONTENT"; then
  echo "✅ Salvo no Obsidian: _claude-brain/global/journals/$DATE.md"
else
  echo "❌ Erro ao salvar no Obsidian"
  exit 1
fi

# 2. Salvar no Inkdrop (SE HABILITADO)
if is_inkdrop_enabled; then
  if save_to_inkdrop_journal "$PROJECT" "$DATE" "$START_TIME" "$END_TIME" "$CONTENT"; then
    echo "✅ Salvo no Inkdrop: Journal $PROJECT — $DATE"
  else
    echo "⚠️  Inkdrop indisponível (salvo apenas no Obsidian)"
  fi
else
  echo "ℹ️  Inkdrop desabilitado (salvo apenas no Obsidian)"
fi
