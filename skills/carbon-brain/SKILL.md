---
name: carbon-brain
description: >
  Use when starting a session (context loaded automatically via hooks),
  saving session summaries, searching past decisions, managing project
  knowledge, or documenting learnings. Also use when user mentions
  "brain", "memory", "context", "save session", "learnings", or
  "past decisions".
---

# carbon-brain

Sistema de memória persistente para Claude Code com duas camadas:

**🗂️ Obsidian** - Segundo cérebro do projeto (vault local)
**📔 Inkdrop** - Journal pessoal (API HTTP opcional)

Contexto carregado automaticamente via hooks no início da sessão. Sessões salvas automaticamente ao encerrar.

## Quick Reference

| Comando | Quando Usar | Salva Em |
|---------|-------------|----------|
| `/brain-save` | Fim de sessão, tarefa concluída | Obsidian journals/ + Inkdrop |
| `/brain-learn` | Descobrir conhecimento reutilizável | global/learnings.md |
| `/brain-error` | Resolver erro não óbvio | global/errors-solved.md |
| `/brain-search` | Buscar em projetos específicos | Busca Obsidian cross-project |
| `/brain-search-patterns` | Buscar aprendizados gerais | Busca Inkdrop (tags filtradas) |
| `/brain-context` | Ver contexto carregado | Exibe contexto atual |
| `/brain-plan` | Criar/atualizar plano | projects/$PROJECT/project-context.md |
| `/brain-test` | Diagnosticar problemas | Verifica instalação completa |
| `/brain-setup` | Configurar notebook Inkdrop | Lista notebooks disponíveis |

## Arquitetura

### Obsidian (sempre ativo)
Lê/escreve direto no filesystem:
```bash
source ~/.claude/hooks/lib-carbon-brain.sh
load_config  # Carrega de ~/.carbon-brain/.env
save_to_obsidian_journal "$PROJECT" "$DATE" "$START" "$END" "$CONTENT"
```

### Inkdrop (opcional)
API HTTP local na porta 19840:
```bash
if is_inkdrop_enabled; then
  save_to_inkdrop_journal "$PROJECT" "$DATE" "$START" "$END" "$CONTENT"
fi
```

### Estrutura de Conhecimento
```
_claude-brain/
├── projects/
│   └── nome-projeto/
│       ├── project-context.md   # Contexto específico
│       └── decision-log.md      # Decisões técnicas
└── global/
    ├── journals/                # Sessões (temporal)
    ├── learnings.md             # Aprendizados (atemporal)
    ├── errors-solved.md         # Erros resolvidos
    └── patterns.md              # Padrões de código
```

## Diferenças Entre Arquivos

- **journals/** → O que fiz hoje (temporal, automático)
- **learnings.md** → Regras reutilizáveis (atemporal, manual via `/brain-learn`)
- **errors-solved.md** → Erros documentados (manual via `/brain-error`)
- **decision-log.md** → Decisões específicas do projeto

## Regras Importantes

- **Sempre** salve decisões importantes imediatamente no decision-log.md
- **Sempre** use `/brain-save` ao encerrar sessão
- **Use** `/brain-learn` quando descobrir conhecimento reutilizável
- **Use** `/brain-error` quando resolver erro não óbvio
- **Mantenha** notas concisas (bullet points, não parágrafos)
- **Prefira** `/brain-search` para projetos, `/brain-search-patterns` para aprendizados gerais

## Economia de Tokens

**CRÍTICO:** Contexto carregado consome ~1500-3000 tokens por sessão.

**Mantenha conciso:**
- ✅ Bullet points (não parágrafos)
- ✅ Max 500-1000 linhas TOTAL em preferências
- ✅ Exemplos curtos (3-5 linhas)
- ❌ Não explique conceitos básicos
- ❌ Não repita informação

**Desabilitar temporariamente:**
```bash
CARBON_BRAIN_SKIP=1 claude  # Economiza ~3000 tokens
```

## Referências Detalhadas

- **Comandos completos:** [commands-reference.md](reference/commands-reference.md)
- **Exemplos executáveis:** Ver [examples/](examples/)
- **Biblioteca:** [lib-carbon-brain.sh](../../hooks/lib-carbon-brain.sh) (funções helper)

## Common Mistakes

- ❌ Escrever notas verbosas → Use bullet points
- ❌ Não usar `/brain-save` ao encerrar → Perde contexto da sessão
- ❌ Documentar em learnings.md coisas específicas do projeto → Use decision-log.md
- ❌ Usar `/brain-search` para buscar aprendizados gerais → Use `/brain-search-patterns`

## Tags Recomendadas (Inkdrop)

- `#claude-journal` → Sessões de trabalho
- `#claude-pattern` → Padrões de código
- `#claude-aprendizado` → Aprendizados gerais
- `#claude-erro-resolvido` → Erros documentados
- `#claude-preferencia` → Preferências pessoais
