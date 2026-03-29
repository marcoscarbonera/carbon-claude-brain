#!/usr/bin/env bash
# Diagnóstico do carbon-claude-brain

echo "🧠 carbon-claude-brain — Diagnóstico"
echo "======================================"
echo ""

# Ler config
CONFIG="$HOME/.carbon-brain/config"
if [ ! -f "$CONFIG" ]; then
  echo "❌ Config não encontrado: $CONFIG"
  echo "   Execute: ./install.sh"
  exit 1
fi

source "$CONFIG"

# 1. Verificar hooks
echo "🔍 Verificando hooks..."
HOOKS_OK=true
for hook in carbon-brain-start.sh carbon-brain-end.sh carbon-brain-post-tool.sh; do
  if [ -x "$HOME/.claude/hooks/$hook" ]; then
    echo "  ✅ $hook"
  else
    echo "  ❌ $hook não encontrado ou sem permissão de execução"
    HOOKS_OK=false
  fi
done
echo ""

# 2. Verificar skills
echo "🔍 Verificando skills..."
SKILLS_OK=true
for skill in brain obsidian inkdrop; do
  if [ -f "$HOME/.claude/skills/$skill/SKILL.md" ]; then
    echo "  ✅ $skill/SKILL.md"
  else
    echo "  ❌ $skill/SKILL.md não encontrado"
    SKILLS_OK=false
  fi
done
echo ""

# 3. Verificar Obsidian vault
echo "🔍 Verificando Obsidian vault..."
if [ -d "$OBSIDIAN_VAULT" ]; then
  echo "  ✅ Vault acessível: $OBSIDIAN_VAULT"

  # Verificar estrutura _claude-brain
  if [ -d "$OBSIDIAN_VAULT/_claude-brain" ]; then
    echo "  ✅ Estrutura _claude-brain existe"
  else
    echo "  ⚠️  Estrutura _claude-brain não existe (será criada na primeira sessão)"
  fi
else
  echo "  ❌ Vault não encontrado: $OBSIDIAN_VAULT"
  echo "     Edite: ~/.carbon-brain/config"
fi
echo ""

# 4. Verificar Inkdrop API
echo "🔍 Verificando Inkdrop API..."
INKDROP_RESPONSE=$(curl -s --max-time 3 -u "$INKDROP_USER:$INKDROP_PASS" "$INKDROP_URL/notes?limit=1" 2>&1)
CURL_EXIT=$?

if [ $CURL_EXIT -eq 0 ] && echo "$INKDROP_RESPONSE" | grep -q '"items"'; then
  echo "  ✅ Inkdrop API respondendo em $INKDROP_URL"

  # Contar notas
  NOTE_COUNT=$(echo "$INKDROP_RESPONSE" | node -e "
    try {
      const d = JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));
      console.log(d.count || 0);
    } catch(e) { console.log('?'); }
  " 2>/dev/null)
  echo "  ℹ️  Total de notas: $NOTE_COUNT"
else
  echo "  ❌ Falha ao conectar com Inkdrop"
  echo "     URL: $INKDROP_URL"
  echo "     Verifique se o servidor local está ativo:"
  echo "     Inkdrop → Preferences → Integrations → Local REST API Server → Start"
fi
echo ""

# 5. Verificar registros no settings.json
echo "🔍 Verificando settings.json..."
if grep -q "carbon-brain" "$HOME/.claude/settings.json" 2>/dev/null; then
  echo "  ✅ Hooks registrados no settings.json"
else
  echo "  ❌ Hooks não estão registrados no settings.json"
  echo "     Execute: ./install.sh"
fi
echo ""

# Resumo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$HOOKS_OK" = true ] && [ "$SKILLS_OK" = true ]; then
  echo "✅ Setup OK! carbon-claude-brain está pronto para usar."
else
  echo "⚠️  Alguns problemas encontrados. Veja acima."
  echo "   Tente reinstalar: ./uninstall.sh && ./install.sh"
fi
echo ""
