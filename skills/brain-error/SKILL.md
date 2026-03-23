---
name: brain-error
description: >
  Registra erro resolvido em global/errors-solved.md.
  Use quando resolver erro não óbvio para evitar repetição.
---

# /brain-error — Documentar Erro Resolvido

Registra um erro resolvido em `_claude-brain/global/errors-solved.md`.

## Quando usar

Use quando resolver **erro não óbvio**:

- ✅ Erro que demorou para descobrir
- ✅ Solução não intuitiva
- ✅ Erro que pode acontecer de novo
- ✅ Lição importante para não repetir

❌ **Não use** para:
- Erros óbvios (typo, sintaxe)
- Bugs pontuais de lógica
- Erros com solução no primeiro Google result

## Implementação

```bash
#!/usr/bin/env bash
source ~/.claude/hooks/lib-carbon-brain.sh
load_config

# Função: save_error_solved(date, title, context, error_msg, solution, prevention)

DATE="$(date '+%Y-%m-%d')"

echo "📝 Documentar Erro Resolvido"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "Título do erro: " TITLE
read -p "Contexto (o que estava fazendo): " CONTEXT
read -p "Mensagem de erro: " ERROR_MSG
read -p "Solução encontrada: " SOLUTION
read -p "Como prevenir no futuro: " PREVENTION

if save_error_solved "$DATE" "$TITLE" "$CONTEXT" "$ERROR_MSG" "$SOLUTION" "$PREVENTION"; then
  echo ""
  echo "✅ Erro documentado em global/errors-solved.md"
else
  echo ""
  echo "❌ Erro ao documentar"
  exit 1
fi
```

## Exemplos de uso

### Exemplo 1: NullPointerException

```bash
/brain-error

# Entrada:
Título: NullPointerException ao acessar user.profile
Contexto: Fazendo update de perfil do usuário após login
Mensagem de erro: Cannot read property 'name' of null
Solução: Adicionar verificação: if (user.profile) antes de acessar
Prevenção: Sempre validar que objetos nested existem antes de acessar propriedades
```

### Exemplo 2: Docker Build

```bash
/brain-error

# Entrada:
Título: Docker build failing com EACCES
Contexto: Tentando build imagem Node.js no CI
Mensagem de erro: EACCES: permission denied, mkdir '/app/node_modules'
Solução: Adicionar USER node antes de RUN npm install no Dockerfile
Prevenção: Nunca rodar npm install como root em containers
```

### Exemplo 3: Race Condition

```bash
/brain-error

# Entrada:
Título: Race condition em testes com setTimeout
Contexto: Testes falhando aleatoriamente em CI
Mensagem de erro: Expected value to be 'complete', received 'pending'
Solução: Substituir setTimeout por waitFor() do testing-library
Prevenção: Usar helpers de espera (waitFor, waitForElement) ao invés de timers fixos
```

## Estrutura do errors-solved.md

```markdown
---
updated: 2026-03-22
tags: [errors, troubleshooting]
---

# Erros Resolvidos

## 2026-03-22 — NullPointerException ao acessar user.profile

**Contexto:**
Fazendo update de perfil do usuário após login

**Erro:**
```
Cannot read property 'name' of null
```

**Solução:**
Adicionar verificação: `if (user.profile)` antes de acessar

**Como prevenir:**
Sempre validar que objetos nested existem antes de acessar propriedades

---

## 2026-03-21 — Docker build failing com EACCES

**Contexto:**
Tentando build imagem Node.js no CI

**Erro:**
```
EACCES: permission denied, mkdir '/app/node_modules'
```

**Solução:**
Adicionar `USER node` antes de `RUN npm install` no Dockerfile

**Como prevenir:**
Nunca rodar npm install como root em containers

---

## 2026-03-20 — Race condition em testes

**Contexto:**
Testes falhando aleatoriamente em CI

**Erro:**
```
Expected value to be 'complete', received 'pending'
```

**Solução:**
Substituir `setTimeout` por `waitFor()` do testing-library

**Como prevenir:**
Usar helpers de espera (waitFor, waitForElement) ao invés de timers fixos
```

## Campos obrigatórios

1. **Data** - Quando o erro foi resolvido
2. **Título** - Resumo do erro em 1 linha
3. **Contexto** - O que você estava fazendo
4. **Erro** - Mensagem de erro exata
5. **Solução** - Como você resolveu
6. **Prevenção** - Como evitar no futuro

## Diferença de outros comandos

- `/brain-error` → Erro **específico resolvido** (errors-solved.md)
- `/brain-learn` → Aprendizado **geral e reutilizável** (learnings.md)
- `/brain-save` → Resumo da **sessão atual** (journals/)

## Buscar erros passados

Use `/brain-search-patterns` para buscar erros similares:

```bash
/brain-search-patterns "NullPointerException"
/brain-search-patterns "EACCES"
/brain-search-patterns "race condition"
```

## Função helper

Definida em `lib-carbon-brain.sh`:

```bash
save_error_solved() {
  local date="$1"
  local title="$2"
  local context="$3"
  local error_msg="$4"
  local solution="$5"
  local prevention="$6"

  local file="$OBSIDIAN_VAULT/_claude-brain/global/errors-solved.md"

  # Criar arquivo se não existir
  if [ ! -f "$file" ]; then
    cat > "$file" << 'EOF'
---
updated: {{DATE}}
tags: [errors, troubleshooting]
---

# Erros Resolvidos

EOF
    sed -i.bak "s/{{DATE}}/$date/" "$file"
    rm "$file.bak" 2>/dev/null
  fi

  # Adicionar erro
  cat >> "$file" << EOF

## $date — $title

**Contexto:**
$context

**Erro:**
\`\`\`
$error_msg
\`\`\`

**Solução:**
$solution

**Como prevenir:**
$prevention

---
EOF

  # Atualizar data
  sed -i.bak "s/^updated: .*/updated: $date/" "$file"
  rm "$file.bak" 2>/dev/null

  return 0
}
```

## Template rápido

Cole no terminal para documentar rapidamente:

```bash
/brain-error << 'INPUT'
Título: [descrição do erro]
Contexto: [o que estava fazendo]
Erro: [mensagem exata]
Solução: [como resolveu]
Prevenção: [como evitar]
INPUT
```
