---
name: carbon-brain-learn
description: >
  Salva aprendizado reutilizável em global/learnings.md.
  Use quando descobrir regra geral que vale para qualquer projeto.
---

# /brain-learn — Salvar Aprendizado

Salva um aprendizado reutilizável em `_claude-brain/global/learnings.md`.

## Quando usar

Use quando descobrir **conhecimento reutilizável**:

- ✅ Regras gerais que valem para qualquer projeto
- ✅ Melhores práticas descobertas na prática
- ✅ Padrões que funcionaram bem
- ✅ Erros comuns e como evitar

❌ **Não use** para:
- Detalhes específicos de um projeto (use decision-log.md)
- Bugs pontuais (use /brain-error)
- Tarefas temporais (use /brain-save)

## Implementação

```bash
#!/usr/bin/env bash
source ~/.claude/hooks/lib-carbon-brain.sh
load_config

# Função: save_learning(category, learning)
# Categorias: Desenvolvimento, Arquitetura, Performance, Segurança, Testing, DevOps

CATEGORY="$1"
LEARNING="$2"

if [ -z "$CATEGORY" ] || [ -z "$LEARNING" ]; then
  echo "❌ Uso: /brain-learn \"Categoria\" \"Aprendizado\""
  echo ""
  echo "Categorias disponíveis:"
  echo "  - Desenvolvimento"
  echo "  - Arquitetura"
  echo "  - Performance"
  echo "  - Segurança"
  echo "  - Testing"
  echo "  - DevOps"
  exit 1
fi

if save_learning "$CATEGORY" "$LEARNING"; then
  echo "✅ Aprendizado salvo em global/learnings.md"
else
  echo "❌ Erro ao salvar aprendizado"
  exit 1
fi
```

## Exemplos de uso

```bash
# Performance
/brain-learn "Performance" "Sempre adicionar índice em colunas usadas em WHERE/JOIN"

# Segurança
/brain-learn "Segurança" "Validar e sanitizar TODOS os inputs do usuário, mesmo internos"

# Arquitetura
/brain-learn "Arquitetura" "Preferir composição a herança - mais flexível e testável"

# Testing
/brain-learn "Testing" "Mockar apenas dependências externas, não lógica interna"

# Desenvolvimento
/brain-learn "Desenvolvimento" "Usar async/await ao invés de .then() - código mais legível"

# DevOps
/brain-learn "DevOps" "Sempre ter health check endpoint para load balancers"
```

## Categorias disponíveis

### Desenvolvimento
Práticas gerais de código, patterns, convenções

**Exemplos:**
- "Preferir const sobre let, nunca usar var"
- "Extrair magic numbers para constantes nomeadas"
- "Single Responsibility: uma função faz uma coisa só"

### Arquitetura
Decisões estruturais, organização de código

**Exemplos:**
- "Feature folders ao invés de type folders (components/, services/)"
- "Dependency injection facilita testes e manutenção"
- "Separar lógica de negócio de framework"

### Performance
Otimizações, caching, eficiência

**Exemplos:**
- "Usar debounce em inputs de busca (300ms)"
- "Implementar pagination para listas >100 itens"
- "Cache de queries caras com TTL de 5min"

### Segurança
Vulnerabilidades, validação, autenticação

**Exemplos:**
- "Nunca confiar em dados do cliente, validar no backend"
- "Hash passwords com bcrypt (min 10 rounds)"
- "Rate limiting: 100 req/min por IP"

### Testing
Estratégias de teste, patterns, cobertura

**Exemplos:**
- "Arrange-Act-Assert pattern para clareza"
- "Testar comportamento, não implementação"
- "Mínimo 80% coverage em lógica de negócio"

### DevOps
Deploy, CI/CD, infraestrutura, monitoramento

**Exemplos:**
- "Blue-green deployment para zero downtime"
- "Sempre ter rollback plan antes de deploy"
- "Logs estruturados (JSON) facilitam parsing"

## Estrutura do learnings.md

```markdown
---
updated: 2026-03-22
tags: [learnings, knowledge-base]
---

# Aprendizados Globais

## Desenvolvimento

- **2026-03-22:** Usar async/await ao invés de .then() - código mais legível
- **2026-03-20:** Preferir const sobre let, nunca usar var
- **2026-03-18:** Single Responsibility: uma função faz uma coisa só

## Arquitetura

- **2026-03-21:** Feature folders > type folders para escalabilidade
- **2026-03-19:** Dependency injection facilita testes
- **2026-03-15:** Separar lógica de negócio de framework

## Performance

- **2026-03-22:** Usar debounce em inputs de busca (300ms)
- **2026-03-20:** Sempre adicionar índice em colunas WHERE/JOIN
- **2026-03-17:** Cache queries caras com TTL 5min

## Segurança

- **2026-03-21:** Validar TODOS os inputs, mesmo internos
- **2026-03-19:** Hash passwords com bcrypt (min 10 rounds)
- **2026-03-16:** Rate limiting: 100 req/min por IP

## Testing

- **2026-03-20:** AAA pattern (Arrange-Act-Assert)
- **2026-03-18:** Testar comportamento, não implementação
- **2026-03-15:** Mínimo 80% coverage em lógica de negócio

## DevOps

- **2026-03-21:** Blue-green deployment para zero downtime
- **2026-03-19:** Sempre ter rollback plan antes de deploy
- **2026-03-17:** Logs estruturados (JSON) facilitam parsing
```

## Diferença de outros comandos

- `/brain-learn` → Aprendizado **geral e reutilizável** (learnings.md)
- `/brain-error` → Erro **específico resolvido** (errors-solved.md)
- `/brain-save` → Resumo da **sessão atual** (journals/)
- `/brain-plan` → Contexto **específico do projeto** (project-context.md)

## Função helper

Definida em `lib-carbon-brain.sh`:

```bash
save_learning() {
  local category="$1"
  local learning="$2"
  local date=$(date '+%Y-%m-%d')
  local file="$OBSIDIAN_VAULT/_claude-brain/global/learnings.md"

  # Criar arquivo se não existir
  if [ ! -f "$file" ]; then
    cat > "$file" << 'EOF'
---
updated: {{DATE}}
tags: [learnings, knowledge-base]
---

# Aprendizados Globais

## Desenvolvimento
## Arquitetura
## Performance
## Segurança
## Testing
## DevOps
EOF
    sed -i.bak "s/{{DATE}}/$date/" "$file"
    rm "$file.bak" 2>/dev/null
  fi

  # Adicionar aprendizado na categoria
  sed -i.bak "/## $category/a\\
- **$date:** $learning
" "$file"
  rm "$file.bak" 2>/dev/null

  # Atualizar data
  sed -i.bak "s/^updated: .*/updated: $date/" "$file"
  rm "$file.bak" 2>/dev/null

  return 0
}
```
