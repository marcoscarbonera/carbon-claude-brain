---
name: carbon-brain-context
description: >
  Mostra o contexto atual carregado do Obsidian para o projeto.
  Exibe: project-context.md, decision-log.md e últimas decisões.
---

# /brain-context — Ver Contexto do Projeto

Mostra o contexto atual carregado para o projeto em que você está trabalhando.

## O que mostra

1. **Project Context** - `project-context.md`
   - Visão geral do projeto
   - Arquitetura
   - Stack tecnológica

2. **Decision Log** - `decision-log.md` (últimas 20 linhas)
   - Decisões técnicas recentes
   - Mudanças de arquitetura
   - Escolhas de bibliotecas

3. **Last Session** - Último journal do projeto
   - O que foi feito na última sessão
   - Onde parou
   - Próximos passos

## Implementação

```bash
#!/usr/bin/env bash
source ~/.claude/hooks/lib-carbon-brain.sh
load_config

PROJECT="$(basename "$(pwd)")"
PROJECT_DIR="$OBSIDIAN_VAULT/_claude-brain/projects/$PROJECT"

echo "🧠 Contexto do projeto: $PROJECT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. Project Context
if [ -f "$PROJECT_DIR/project-context.md" ]; then
  echo "📋 PROJECT CONTEXT"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  cat "$PROJECT_DIR/project-context.md"
  echo ""
else
  echo "⚠️  project-context.md não existe ainda"
  echo "   Use /brain-plan para criar"
  echo ""
fi

# 2. Decision Log (últimas 20 linhas)
if [ -f "$PROJECT_DIR/decision-log.md" ]; then
  echo "📝 DECISÕES RECENTES"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  tail -n 20 "$PROJECT_DIR/decision-log.md"
  echo ""
else
  echo "ℹ️  Nenhuma decisão registrada ainda"
  echo ""
fi

# 3. Última sessão (do journal global)
LATEST_JOURNAL=$(ls -t "$OBSIDIAN_VAULT/_claude-brain/global/journals"/*.md 2>/dev/null | head -1)

if [ -n "$LATEST_JOURNAL" ]; then
  echo "📅 ÚLTIMA SESSÃO"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Extrair apenas a parte relevante ao projeto atual
  grep -A 20 "Project: $PROJECT" "$LATEST_JOURNAL" 2>/dev/null || echo "Nenhuma sessão recente para este projeto"
  echo ""
else
  echo "ℹ️  Nenhuma sessão salva ainda"
  echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 Dicas:"
echo "   /brain-plan    - Atualizar contexto do projeto"
echo "   /brain-save    - Salvar sessão atual"
echo "   /brain-search  - Buscar em outros projetos"
echo ""
```

## Quando usar

- **Início de sessão** - para relembrar onde parou
- Ao retornar a um projeto após **tempo sem trabalhar**
- Antes de **tomar decisão técnica** (ver decisões passadas)
- Para **entender arquitetura** existente
- Quando alguém perguntar "como funciona X?"

## Estrutura do contexto carregado

```
🧠 Contexto do projeto: carbon-claude-brain
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 PROJECT CONTEXT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# carbon-claude-brain

Sistema de memória persistente para Claude Code.

## Stack
- Bash scripts (hooks)
- Obsidian (vault local)
- Inkdrop (API REST local)

## Arquitetura
- Hooks: session-start → post-tool → session-end
- Skills: /brain-*, /obsidian-*, /inkdrop-*

📝 DECISÕES RECENTES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- 2026-03-20: Usar .env ao invés de config bash
- 2026-03-19: Adicionar global/ para knowledge cross-project
- 2026-03-18: Inkdrop opcional, Obsidian obrigatório

📅 ÚLTIMA SESSÃO
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Project: carbon-claude-brain
Time: 14:30 - 16:45

### O que foi feito
- Implementei skills individuais para autocomplete
- Atualizei install.sh

### Próximos passos
- [ ] Testar instalação completa
- [ ] Atualizar documentação
```
