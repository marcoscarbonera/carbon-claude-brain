---
name: carbon-brain-inkdrop
description: >
  Skill para interagir com o Inkdrop via API HTTP local (porta 19840).
  Use para criar e buscar journals de sessão, aprendizados e notas rápidas.
  Trigger: quando o usuário mencionar "inkdrop", "journal", "aprendizados",
  "diário" ou ao encerrar uma sessão de trabalho.
---

# Inkdrop — Journal do Claude

O Inkdrop é o **diário pessoal** das sessões. Sincroniza online, acessível
em qualquer máquina. Ideal para histórico de sessões e aprendizados.

## Autenticação

```bash
source ~/.carbon-brain/config
# Variáveis: $INKDROP_URL, $INKDROP_USER, $INKDROP_PASS
AUTH="-u $INKDROP_USER:$INKDROP_PASS"
```

## Operações básicas

### Criar nota de journal

```bash
source ~/.carbon-brain/config
PROJECT="$(basename $(pwd))"
TODAY="$(date '+%Y-%m-%d')"

curl -s -u "$INKDROP_USER:$INKDROP_PASS" \
  -X POST "$INKDROP_URL/notes" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Journal $PROJECT — $TODAY\",
    \"body\": \"## O que foi feito\n\n...\n\n## Erros e aprendizados\n\n...\n\n## Próximos passos\n\n...\",
    \"tags\": [\"claude-journal\", \"$PROJECT\"]
  }"
```

### Buscar journals anteriores

```bash
source ~/.carbon-brain/config
PROJECT="$(basename $(pwd))"

curl -s -u "$INKDROP_USER:$INKDROP_PASS" \
  "$INKDROP_URL/notes?keyword=claude-journal+$PROJECT&limit=5"
```

### Criar nota de aprendizado

```bash
source ~/.carbon-brain/config

curl -s -u "$INKDROP_USER:$INKDROP_PASS" \
  -X POST "$INKDROP_URL/notes" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Aprendizado: TITULO\",
    \"body\": \"## Problema\n\n...\n\n## Solução\n\n...\n\n## Referência\n\n...\",
    \"tags\": [\"claude-aprendizado\"]
  }"
```

## Tags padrão

| Tag | Uso |
|---|---|
| `claude-journal` | Resumo de sessão (criado automaticamente) |
| `claude-aprendizado` | Erros resolvidos, padrões descobertos |
| `claude-decisao` | Decisões rápidas que não cabem no Obsidian |
| `{nome-do-projeto}` | Sempre adicionar o nome do projeto |

## Formato do journal de sessão

```markdown
## O que foi feito
- Item 1
- Item 2

## Erros e aprendizados
- Erro encontrado: descrição
  Solução: como foi resolvido

## Próximos passos
- [ ] Tarefa pendente 1
- [ ] Tarefa pendente 2

## Tempo de sessão
Início: HH:MM — Fim: HH:MM
```

## Quando usar

| Situação | Ação |
|---|---|
| Encerrar sessão | Criar journal com resumo |
| Resolver bug difícil | Criar nota de aprendizado |
| Decisão rápida | Criar nota com tag `claude-decisao` |
| Início da sessão | Buscar journals do projeto |
