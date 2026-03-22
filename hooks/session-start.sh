#!/usr/bin/env bash
# carbon-claude-brain — session-start.sh
# Carrega contexto do Obsidian e Inkdrop ao iniciar uma sessão

# ── Modo Skip (desabilitar temporariamente) ────────────────────────────────
# Use: CARBON_BRAIN_SKIP=1 claude
# Útil para projetos pequenos/rápidos onde não quer overhead de contexto
if [ "$CARBON_BRAIN_SKIP" = "1" ]; then
  exit 0
fi

# ── Carregar biblioteca e configuração ─────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib-carbon-brain.sh"

# Carregar configuração (.env ou config antigo)
if ! load_config; then
  exit 0
fi

PROJECT_NAME="$(basename "$(pwd)")"
BRAIN_FOLDER="$OBSIDIAN_VAULT/_claude-brain"
OUTPUT=""

# ── Inkdrop: Preferências pessoais (sincronizam entre máquinas) ────────────

# Buscar notas com tag #claude-preferencia no Inkdrop
PREFERENCES_RESPONSE=$(curl -s --max-time 5 \
  -u "$INKDROP_USER:$INKDROP_PASS" \
  "$INKDROP_URL/notes?keyword=claude-preferencia&limit=5" 2>&1)

CURL_PREF_EXIT=$?

if [ $CURL_PREF_EXIT -eq 0 ] && [ -n "$PREFERENCES_RESPONSE" ] && echo "$PREFERENCES_RESPONSE" | grep -q '"_id"'; then
  PREFERENCES_CONTENT=$(echo "$PREFERENCES_RESPONSE" | \
    node -e "
      try {
        const d = JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));
        const items = d.items || [];

        if (items.length > 0) {
          let output = '';
          items.forEach(note => {
            if (note.tags && note.tags.includes('claude-preferencia')) {
              output += '### ' + note.title + '\n\n';
              output += (note.body || '').substring(0, 1000) + '\n\n';
              output += '---\n\n';
            }
          });
          console.log(output);
        }
      } catch (e) {
        process.exit(1);
      }
    " 2>&1)

  PREF_EXIT=$?

  if [ $PREF_EXIT -eq 0 ] && [ -n "$PREFERENCES_CONTENT" ]; then
    OUTPUT+=$'\n\n## ⚙️ Minhas Preferências Pessoais (Inkdrop)\n\n'
    OUTPUT+="$PREFERENCES_CONTENT"
  fi
fi

# ── Obsidian: conhecimento global (learnings, errors, patterns) ────────────

LEARNINGS_FILE="$BRAIN_FOLDER/global/learnings.md"
ERRORS_FILE="$BRAIN_FOLDER/global/errors-solved.md"
PATTERNS_FILE="$BRAIN_FOLDER/global/patterns.md"

if [ -f "$LEARNINGS_FILE" ]; then
  OUTPUT+=$'\n\n## 📚 Aprendizados Gerais (Obsidian)\n\n'
  OUTPUT+="$(cat "$LEARNINGS_FILE")"
fi

if [ -f "$ERRORS_FILE" ]; then
  OUTPUT+=$'\n\n## 🐛 Erros Resolvidos (Obsidian)\n\n'
  OUTPUT+="$(cat "$ERRORS_FILE")"
fi

if [ -f "$PATTERNS_FILE" ]; then
  OUTPUT+=$'\n\n## 🎯 Padrões Reutilizáveis (Obsidian)\n\n'
  OUTPUT+="$(cat "$PATTERNS_FILE")"
fi

# ── Obsidian: contexto do projeto ──────────────────────────────────────────

CONTEXT_FILE="$BRAIN_FOLDER/projects/$PROJECT_NAME/project-context.md"
DECISIONS_FILE="$BRAIN_FOLDER/projects/$PROJECT_NAME/decision-log.md"

if [ -f "$CONTEXT_FILE" ]; then
  OUTPUT+=$'\n\n## 📁 Contexto do Projeto (Obsidian)\n\n'
  OUTPUT+="$(cat "$CONTEXT_FILE")"
fi

if [ -f "$DECISIONS_FILE" ]; then
  OUTPUT+=$'\n\n## 🏛️ Decisões Recentes (Obsidian)\n\n'
  # Apenas as últimas 10 linhas não vazias
  OUTPUT+="$(grep -v '^$' "$DECISIONS_FILE" | tail -20)"
fi

# ── Inkdrop: journal da última sessão ─────────────────────────────────────

YESTERDAY=$(date -v-1d '+%Y-%m-%d' 2>/dev/null || date -d 'yesterday' '+%Y-%m-%d' 2>/dev/null)
TODAY=$(date '+%Y-%m-%d')

# Tentar buscar do Inkdrop com timeout e tratamento de erro
INKDROP_RESPONSE=$(curl -s --max-time 5 \
  -u "$INKDROP_USER:$INKDROP_PASS" \
  "$INKDROP_URL/notes?keyword=claude-journal+$PROJECT_NAME&limit=3" 2>&1)

CURL_EXIT_CODE=$?

if [ $CURL_EXIT_CODE -ne 0 ]; then
  log_error "session-start: Falha ao conectar com Inkdrop (exit code: $CURL_EXIT_CODE)"
  # Continuar sem falhar - Inkdrop é opcional
elif [ -n "$INKDROP_RESPONSE" ] && echo "$INKDROP_RESPONSE" | grep -q '"_id"'; then
  # Tentar parsear JSON
  LAST_JOURNAL=$(echo "$INKDROP_RESPONSE" | \
    node -e "
      try {
        const d = JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));
        const items = d.items || [];
        if (items.length > 0) {
          const last = items[0];
          console.log('**' + last.title + '**\n' + (last.body || '').slice(0, 500));
        }
      } catch (e) {
        // Falha silenciosa - JSON inválido
        process.exit(1);
      }
    " 2>&1)

  NODE_EXIT_CODE=$?

  if [ $NODE_EXIT_CODE -ne 0 ]; then
    log_error "session-start: Falha ao parsear resposta do Inkdrop"
  elif [ -n "$LAST_JOURNAL" ]; then
    OUTPUT+=$'\n\n## 📔 Última Sessão (Inkdrop)\n\n'
    OUTPUT+="$LAST_JOURNAL"
  fi
fi

# ── Injetar no contexto ────────────────────────────────────────────────────

if [ -n "$OUTPUT" ]; then
  echo ""
  echo "---"
  echo "🧠 **carbon-claude-brain** — contexto carregado para \`$PROJECT_NAME\`"
  echo "$OUTPUT"
  echo "---"
  echo ""
fi
