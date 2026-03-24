#!/usr/bin/env bash
# carbon-claude-brain — uninstall.sh
# Remove hooks, skills e configurações do Claude Code

set -e

CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SKILLS_DIR="$CLAUDE_DIR/skills"
CONFIG_DIR="$HOME/.carbon-brain"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

echo ""
echo "🧠 carbon-claude-brain — desinstalação"
echo "========================================"
echo ""

# ── Confirmar desinstalação ────────────────────────────────────────────────

read -rp "⚠️  Tem certeza que deseja desinstalar? (s/N): " CONFIRM
CONFIRM="${CONFIRM,,}" # lowercase

if [ "$CONFIRM" != "s" ] && [ "$CONFIRM" != "sim" ]; then
  echo "❌ Desinstalação cancelada"
  exit 0
fi

echo ""

# ── Remover hooks do settings.json ─────────────────────────────────────────

if [ -f "$SETTINGS_FILE" ]; then
  echo "🔧 Removendo hooks do settings.json..."

  node -e "
const fs = require('fs');
const settingsPath = '$SETTINGS_FILE';

try {
  const settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));

  if (settings.hooks) {
    // Remover hooks do carbon-brain
    ['PreToolUse', 'PostToolUse', 'Stop'].forEach(hookType => {
      if (Array.isArray(settings.hooks[hookType])) {
        settings.hooks[hookType] = settings.hooks[hookType].filter(item => {
          const str = JSON.stringify(item);
          return !str.includes('carbon-brain');
        });
      }
    });
  }

  fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2));
  console.log('✅ Hooks removidos do settings.json');
} catch (e) {
  console.error('⚠️  Erro ao modificar settings.json:', e.message);
  process.exit(1);
}
  "
else
  echo "⚠️  settings.json não encontrado, pulando..."
fi

# ── Remover arquivos de hooks ──────────────────────────────────────────────

echo "🗑️  Removendo hooks..."

rm -f "$HOOKS_DIR/carbon-brain-start.sh"
rm -f "$HOOKS_DIR/carbon-brain-end.sh"
rm -f "$HOOKS_DIR/carbon-brain-post-tool.sh"

echo "✅ Hooks removidos de ~/.claude/hooks/"

# ── Remover skills ─────────────────────────────────────────────────────────

echo "🗑️  Removendo skills..."

rm -rf "$SKILLS_DIR/carbon-brain"*

echo "✅ Skills removidas de ~/.claude/skills/"

# ── Remover configuração (opcional) ────────────────────────────────────────

echo ""
read -rp "🗑️  Remover também as configurações e logs? (~/.carbon-brain) (s/N): " REMOVE_CONFIG
REMOVE_CONFIG="${REMOVE_CONFIG,,}"

if [ "$REMOVE_CONFIG" = "s" ] || [ "$REMOVE_CONFIG" = "sim" ]; then
  if [ -d "$CONFIG_DIR" ]; then
    rm -rf "$CONFIG_DIR"
    echo "✅ Configurações removidas"
  fi
else
  echo "⏭️  Configurações mantidas em ~/.carbon-brain"
  echo "   (Você pode removê-las manualmente depois: rm -rf ~/.carbon-brain)"
fi

echo ""
echo "🎉 Desinstalação concluída!"
echo ""
echo "   Para reinstalar, execute: ./install.sh"
echo ""
