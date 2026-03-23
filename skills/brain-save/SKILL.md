---
name: brain-save
description: >
  Salva resumo da sessão atual em Obsidian (journals/) e Inkdrop.
  Use ao encerrar sessão ou quando descobrir algo importante.
---

# /brain-save — Salvar Sessão

Salva o resumo da sessão de trabalho em **ambos** Obsidian e Inkdrop.

## Onde salva

**Obsidian (SEMPRE):**
- `_claude-brain/global/journals/YYYY-MM-DD.md`
- Formato: markdown com frontmatter YAML
- Múltiplas sessões no mesmo dia = append com separador

**Inkdrop (SE CONFIGURADO):**
- Se `INKDROP_URL` vazio → pula Inkdrop
- Se configurado → salva com tag `#claude-journal`
- Se servidor offline → warning, continua com Obsidian

## Implementação

```bash
#!/usr/bin/env bash
source ~/.claude/hooks/lib-carbon-brain.sh
load_config

PROJECT="$(basename "$(pwd)")"
DATE="$(date '+%Y-%m-%d')"
START_TIME="14:30"  # Pegar do trigger file se disponível
END_TIME="$(date '+%H:%M')"

# Preparar conteúdo do resumo
CONTENT="### O que foi feito
- [Liste aqui o que foi implementado]

### Erros e aprendizados
- [Erros encontrados e soluções]

### Próximos passos
- [ ] [Tarefas pendentes]"

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
```

## Template do resumo

```markdown
### O que foi feito
- Implementei feature X
- Corrigi bug Y no módulo Z
- Refatorei componente A

### Decisões técnicas
- Escolhi biblioteca X ao invés de Y porque [razão]
- Mudei arquitetura de A para B para [motivo]

### Erros e aprendizados
- Erro: timeout na API
  Solução: aumentei timeout para 5s
- Aprendi: sempre validar inputs antes de processar

### Próximos passos
- [ ] Adicionar testes unitários
- [ ] Atualizar documentação
- [ ] Deploy em staging
```

## Quando usar

- **Ao encerrar sessão** de trabalho (automático via SessionEnd hook)
- Quando descobrir **aprendizado importante**
- Após resolver **erro complexo**
- Ao tomar **decisão técnica** significativa
- Fim de implementação de **feature grande**

## Funções helper disponíveis

Definidas em `lib-carbon-brain.sh`:

- `save_to_obsidian_journal()` - Salva no Obsidian
- `save_to_inkdrop_journal()` - Salva no Inkdrop
- `is_inkdrop_enabled()` - Verifica se Inkdrop está configurado
