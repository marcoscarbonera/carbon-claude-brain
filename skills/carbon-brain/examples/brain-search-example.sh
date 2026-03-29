#!/usr/bin/env bash
# Busca cross-project no Obsidian

source ~/.carbon-brain/config

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
      # Extrair: arquivo:linha:conteudo
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
