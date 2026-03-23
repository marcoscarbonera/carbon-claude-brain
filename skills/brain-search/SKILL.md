---
name: brain-search
description: >
  Busca cross-project em todos os projetos do Obsidian vault.
  Use para encontrar soluções ou decisões passadas em qualquer projeto.
---

# /brain-search — Busca Cross-Project

Busca um termo em **todos os projetos** do Obsidian vault.

## O que busca

- Todos os arquivos `.md` em `_claude-brain/projects/*/`
- Case-insensitive
- Mostra: projeto, arquivo, linha e conteúdo

## Como usar

```bash
/brain-search "authentication"
/brain-search "rate limiting redis"
/brain-search "docker compose"
```

## Implementação

```bash
#!/usr/bin/env bash
source ~/.claude/hooks/lib-carbon-brain.sh
load_config

SEARCH_TERM="$1"

if [ -z "$SEARCH_TERM" ]; then
  echo "❌ Uso: /brain-search \"termo de busca\""
  exit 1
fi

echo "🔍 Buscando '$SEARCH_TERM' em todos os projetos..."
echo ""

PROJECTS_DIR="$OBSIDIAN_VAULT/_claude-brain/projects"

if [ ! -d "$PROJECTS_DIR" ]; then
  echo "❌ Nenhum projeto encontrado em $PROJECTS_DIR"
  exit 1
fi

RESULTS_FOUND=0

# Buscar em cada projeto
for project_path in "$PROJECTS_DIR"/*; do
  if [ ! -d "$project_path" ]; then
    continue
  fi

  project_name=$(basename "$project_path")

  # Buscar em todos os .md do projeto (case insensitive)
  matches=$(grep -riHn --color=never "$SEARCH_TERM" "$project_path"/*.md 2>/dev/null)

  if [ -n "$matches" ]; then
    RESULTS_FOUND=$((RESULTS_FOUND + 1))

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📁 Projeto: $project_name"
    echo ""

    # Processar cada match
    while IFS= read -r line; do
      file=$(echo "$line" | cut -d: -f1)
      line_num=$(echo "$line" | cut -d: -f2)
      content=$(echo "$line" | cut -d: -f3-)

      file_name=$(basename "$file")

      echo "  📄 $file_name:$line_num"
      echo "     $content"
      echo ""
    done <<< "$matches"
  fi
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$RESULTS_FOUND" -eq 0 ]; then
  echo "❌ Nenhum resultado encontrado para '$SEARCH_TERM'"
  echo ""
  echo "💡 Dicas:"
  echo "   - Tente termos mais genéricos"
  echo "   - Verifique a ortografia"
  echo "   - Use /brain-context para ver o projeto atual"
else
  echo "✅ Encontrado em $RESULTS_FOUND projeto(s)"
fi

echo ""
```

## Casos de uso

- Lembrar como você resolveu problema similar em outro projeto
- Encontrar decisões técnicas relacionadas a uma tecnologia
- Ver padrões que você usa em múltiplos projetos
- Descobrir aprendizados passados sobre um tema

## Exemplo de output

```
🔍 Buscando 'authentication' em todos os projetos...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📁 Projeto: e-commerce-api

  📄 decision-log.md:12
     Decidimos usar JWT para authentication ao invés de sessions

  📄 architecture.md:45
     Authentication flow: login → JWT token → middleware validation

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📁 Projeto: admin-dashboard

  📄 project-context.md:8
     Frontend authentication via OAuth2 + backend JWT

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Encontrado em 2 projeto(s)
```

## Diferença de /brain-search-patterns

- `/brain-search` → Busca no **Obsidian** (projetos específicos)
- `/brain-search-patterns` → Busca no **Inkdrop** (aprendizados gerais)
