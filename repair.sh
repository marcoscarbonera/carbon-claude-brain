#!/usr/bin/env bash
# carbon-claude-brain — repair.sh
# Corrige problemas comuns na instalação dos hooks

set -e

CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

echo ""
echo "🔧 carbon-claude-brain — repair"
echo "================================="
echo ""

# Verificar se settings.json existe
if [ ! -f "$SETTINGS_FILE" ]; then
  echo "❌ Erro: $SETTINGS_FILE não encontrado"
  echo "   Execute ./install.sh primeiro"
  exit 1
fi

# Verificar node
if ! command -v node &> /dev/null; then
  echo "❌ Erro: node não está instalado"
  exit 1
fi

# Fazer backup
BACKUP_FILE="$SETTINGS_FILE.backup-$(date +%Y%m%d-%H%M%S)"
cp "$SETTINGS_FILE" "$BACKUP_FILE"
echo "✅ Backup criado: $BACKUP_FILE"
echo ""

# Detectar e corrigir problemas
echo "🔍 Detectando problemas..."

node -e "
const fs = require('fs');

try {
  const settings = JSON.parse(fs.readFileSync('$SETTINGS_FILE', 'utf8'));
  let modified = false;

  // Garantir estrutura básica
  if (!settings.hooks) {
    settings.hooks = {};
    modified = true;
    console.log('✓ Criado settings.hooks');
  }

  // Garantir arrays dos hooks
  ['PreToolUse', 'PostToolUse', 'Stop', 'SessionEnd'].forEach(hookType => {
    if (!Array.isArray(settings.hooks[hookType])) {
      settings.hooks[hookType] = [];
      modified = true;
      console.log(\`✓ Criado settings.hooks.\${hookType}\`);
    }
  });

  // Hook SessionEnd - definir o prompt completo
  const autoSavePrompt = \`You are about to auto-save the session summary for carbon-claude-brain.

INSTRUCTIONS:
1. Read the session transcript file provided in the hook input (transcript_path)
2. Analyze the conversation and generate a concise session summary with:
   - **O que foi feito**: What was accomplished (bullet points)
   - **Erros e aprendizados**: Errors encountered and learnings (if any)
   - **Próximos passos**: Next steps or open items (checkbox list)

3. Save the summary by:
   a. Writing the markdown summary to a temp file: /tmp/brain-summary-\${Date.now()}.md
   b. Running: bash ~/.claude/hooks/auto-save-helper.sh PROJECT_NAME DATE START_TIME END_TIME /tmp/brain-summary-file.md

IMPORTANT:
- Keep summary concise (max 300 words)
- Use markdown format
- Be objective and factual
- If the session was very short (< 3 interactions), save a minimal summary
- Use Portuguese (pt-BR) for the summary content
- Extract project name from current working directory
- Use current date/time for DATE and END_TIME
- Get START_TIME from session start (estimate from transcript timestamps)

DO NOT ask for confirmation - save automatically.\`;

  // Corrigir SessionEnd hook se necessário
  if (settings.hooks.SessionEnd.length > 0) {
    const sessionEndHook = settings.hooks.SessionEnd[0];

    if (sessionEndHook.hooks && sessionEndHook.hooks.length > 0) {
      const agentHook = sessionEndHook.hooks[0];

      // Se é um agent hook mas está sem prompt
      if (agentHook.type === 'agent' && !agentHook.prompt) {
        agentHook.prompt = autoSavePrompt;
        agentHook.model = agentHook.model || 'claude-haiku-4';
        agentHook.timeout = agentHook.timeout || 60000;
        modified = true;
        console.log('✓ Corrigido SessionEnd hook: adicionado campo prompt');
      }
    }
  } else {
    // SessionEnd não existe, criar do zero
    settings.hooks.SessionEnd.push({
      matcher: '',
      hooks: [{
        type: 'agent',
        prompt: autoSavePrompt,
        model: 'claude-haiku-4',
        timeout: 60000
      }]
    });
    modified = true;
    console.log('✓ Criado SessionEnd hook completo');
  }

  // Verificar hooks de comando (PreToolUse, PostToolUse, Stop)
  const commandHooks = {
    PreToolUse: '$HOOKS_DIR/carbon-brain-start.sh',
    PostToolUse: '$HOOKS_DIR/carbon-brain-post-tool.sh',
    Stop: '$HOOKS_DIR/carbon-brain-end.sh'
  };

  Object.entries(commandHooks).forEach(([hookType, command]) => {
    const hasHook = settings.hooks[hookType].some(h =>
      h.hooks && h.hooks.some(ch => ch.command === command)
    );

    if (!hasHook) {
      settings.hooks[hookType].push({
        matcher: '',
        hooks: [{ type: 'command', command }]
      });
      modified = true;
      console.log(\`✓ Adicionado hook \${hookType}\`);
    }
  });

  if (modified) {
    fs.writeFileSync('$SETTINGS_FILE', JSON.stringify(settings, null, 2));
    console.log('');
    console.log('✅ settings.json corrigido com sucesso');
  } else {
    console.log('');
    console.log('✅ Nenhum problema encontrado - settings.json está correto');
  }

  process.exit(0);
} catch (e) {
  console.error('❌ Erro:', e.message);
  process.exit(1);
}
"

REPAIR_EXIT=$?

if [ $REPAIR_EXIT -ne 0 ]; then
  echo ""
  echo "❌ Falha ao reparar. Restaurando backup..."
  cp "$BACKUP_FILE" "$SETTINGS_FILE"
  echo "   Backup restaurado."
  exit 1
fi

echo ""
echo "🎉 Reparo concluído!"
echo ""
echo "   Próximo passo: reinicie o Claude Code para aplicar as correções."
echo ""
