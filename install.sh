#!/usr/bin/env bash
# carbon-claude-brain — install.sh (Refactored)
# Intelligent installation with auto-detection
# Version: 1.0.0

set -e

# Get script directory
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source shared library
# shellcheck source=lib-setup.sh
source "$REPO_DIR/lib-setup.sh"

# Constants
CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SKILLS_DIR="$CLAUDE_DIR/skills"

# Detect mode (marketplace vs manual)
if [ -n "$CLAUDE_PLUGIN_DATA" ]; then
  MODE="marketplace"
  CONFIG_DIR="$CLAUDE_PLUGIN_DATA"
else
  MODE="manual"
  CONFIG_DIR="$HOME/.carbon-brain"
fi

# Dry-run mode
DRY_RUN=false
if [ "$1" = "--dry-run" ]; then
  DRY_RUN=true
  echo "🔍 MODO DRY-RUN (simulação, sem alterações)"
  echo ""
fi

# Safe execute (respects dry-run)
safe_execute() {
  if [ "$DRY_RUN" = true ]; then
    echo "[DRY-RUN] Simularia: $*"
  else
    "$@"
  fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MAIN INSTALLATION FLOW
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

main() {
  # Header
  print_header

  # Check dependencies
  check_dependencies || exit 1

  # Detect upgrade vs fresh install
  local UPGRADE_MODE=false
  if [ -f "$CONFIG_DIR/.env" ] || [ -f "$CONFIG_DIR/config" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔄 Instalação Existente Detectada"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Você já tem carbon-claude-brain instalado."
    echo ""
    echo "Esta atualização irá:"
    echo "  • Atualizar hooks e skills para versão mais recente"
    echo "  • Preservar sua configuração (vault e Inkdrop)"
    echo "  • Migrar 'config' → '.env' se necessário"
    echo ""

    read -rp "Continuar com atualização? [S/n]: " UPGRADE
    if [ "$UPGRADE" = "n" ] || [ "$UPGRADE" = "N" ]; then
      echo "Instalação cancelada."
      exit 0
    fi

    UPGRADE_MODE=true
  fi

  # Check for non-interactive mode
  local NON_INTERACTIVE=false
  if [ -f "$REPO_DIR/.env" ]; then
    # shellcheck source=/dev/null
    source "$REPO_DIR/.env"
    NON_INTERACTIVE=true
    echo "✓ Modo não-interativo detectado (.env encontrado)"
    echo ""
  fi

  # Interactive wizard (if not upgrading and not non-interactive)
  if [ "$UPGRADE_MODE" = false ] && [ "$NON_INTERACTIVE" = false ]; then
    # Step 1: Select Obsidian vault
    select_obsidian_vault || exit 1

    # Step 2: Optionally configure Inkdrop
    echo ""
    read -rp "Configurar Inkdrop? [s/N]: " SETUP_INKDROP

    if [ "$SETUP_INKDROP" = "s" ] || [ "$SETUP_INKDROP" = "S" ]; then
      setup_inkdrop_wizard || {
        # Wizard failed or user skipped
        INKDROP_URL=""
        INKDROP_USER=""
        INKDROP_PASS=""
        INKDROP_NOTEBOOK_ID=""
      }
    else
      INKDROP_URL=""
      INKDROP_USER=""
      INKDROP_PASS=""
      INKDROP_NOTEBOOK_ID=""
      echo "⚠️  Inkdrop desabilitado. Apenas Obsidian será usado."
    fi
  elif [ "$UPGRADE_MODE" = true ]; then
    # Load existing configuration
    echo "🔄 Carregando configuração existente..."

    if [ -f "$CONFIG_DIR/.env" ]; then
      # shellcheck source=/dev/null
      set -a
      source "$CONFIG_DIR/.env"
      set +a
      echo "✓ Configuração carregada de .env"
    elif [ -f "$CONFIG_DIR/config" ]; then
      # shellcheck source=/dev/null
      source "$CONFIG_DIR/config"
      echo "✓ Configuração carregada de config (será migrada para .env)"
    fi
    echo ""
  fi

  # Pre-flight validation
  validate_configuration "$OBSIDIAN_VAULT" "$INKDROP_URL" "$INKDROP_USER" "$INKDROP_PASS" || exit 1

  # Backup existing config (if upgrade)
  if [ "$UPGRADE_MODE" = true ]; then
    backup_existing_config "$CONFIG_DIR"
  fi

  # Create directories
  echo "📁 Criando diretórios..."
  safe_execute mkdir -p "$CONFIG_DIR"
  safe_execute mkdir -p "$HOOKS_DIR"
  safe_execute mkdir -p "$SKILLS_DIR/carbon-brain"
  safe_execute mkdir -p "$SKILLS_DIR/carbon-brain-obsidian"
  safe_execute mkdir -p "$SKILLS_DIR/carbon-brain-inkdrop"
  safe_execute mkdir -p "$SKILLS_DIR/carbon-brain-test"
  safe_execute mkdir -p "$SKILLS_DIR/carbon-brain-save"
  safe_execute mkdir -p "$SKILLS_DIR/carbon-brain-search"
  safe_execute mkdir -p "$SKILLS_DIR/carbon-brain-context"
  safe_execute mkdir -p "$SKILLS_DIR/carbon-brain-plan"
  safe_execute mkdir -p "$SKILLS_DIR/carbon-brain-learn"
  safe_execute mkdir -p "$SKILLS_DIR/carbon-brain-error"
  safe_execute mkdir -p "$SKILLS_DIR/carbon-brain-search-patterns"
  safe_execute mkdir -p "$SKILLS_DIR/carbon-brain-setup"

  # Save configuration
  echo "💾 Salvando configuração..."

  if [ "$DRY_RUN" = false ]; then
    cat > "$CONFIG_DIR/.env" <<EOF
# carbon-claude-brain configuration
# DO NOT COMMIT THIS FILE

OBSIDIAN_VAULT="$OBSIDIAN_VAULT"
INKDROP_URL="$INKDROP_URL"
INKDROP_USER="$INKDROP_USER"
INKDROP_PASS="$INKDROP_PASS"
INKDROP_NOTEBOOK_ID="$INKDROP_NOTEBOOK_ID"
EOF
    chmod 600 "$CONFIG_DIR/.env"
    echo "✅ Configuração salva em $CONFIG_DIR/.env"
  else
    echo "[DRY-RUN] Criaria $CONFIG_DIR/.env com:"
    echo "  OBSIDIAN_VAULT=$OBSIDIAN_VAULT"
    echo "  INKDROP_URL=$INKDROP_URL"
    echo "  ..."
  fi

  # Install hooks
  echo ""
  echo "🔗 Instalando hooks..."

  safe_execute cp "$REPO_DIR/hooks/lib-carbon-brain.sh" "$HOOKS_DIR/lib-carbon-brain.sh"
  safe_execute chmod +x "$HOOKS_DIR/lib-carbon-brain.sh"

  safe_execute cp "$REPO_DIR/hooks/session-start.sh" "$HOOKS_DIR/carbon-brain-start.sh"
  safe_execute cp "$REPO_DIR/hooks/session-end.sh" "$HOOKS_DIR/carbon-brain-end.sh"
  safe_execute cp "$REPO_DIR/hooks/post-tool-use.sh" "$HOOKS_DIR/carbon-brain-post-tool.sh"
  safe_execute cp "$REPO_DIR/hooks/auto-save-helper.sh" "$HOOKS_DIR/auto-save-helper.sh"

  safe_execute chmod +x "$HOOKS_DIR/carbon-brain-start.sh"
  safe_execute chmod +x "$HOOKS_DIR/carbon-brain-end.sh"
  safe_execute chmod +x "$HOOKS_DIR/carbon-brain-post-tool.sh"
  safe_execute chmod +x "$HOOKS_DIR/auto-save-helper.sh"

  echo "✅ Hooks instalados em ~/.claude/hooks/"

  # Install skills
  echo ""
  echo "🧠 Instalando skills..."

  safe_execute cp -r "$REPO_DIR/skills/carbon-brain/"* "$SKILLS_DIR/carbon-brain/"
  safe_execute cp "$REPO_DIR/skills/carbon-brain-obsidian/SKILL.md" "$SKILLS_DIR/carbon-brain-obsidian/SKILL.md"
  safe_execute cp "$REPO_DIR/skills/carbon-brain-inkdrop/SKILL.md" "$SKILLS_DIR/carbon-brain-inkdrop/SKILL.md"

  safe_execute cp "$REPO_DIR/skills/carbon-brain-test/SKILL.md" "$SKILLS_DIR/carbon-brain-test/SKILL.md"
  safe_execute cp "$REPO_DIR/skills/carbon-brain-save/SKILL.md" "$SKILLS_DIR/carbon-brain-save/SKILL.md"
  safe_execute cp "$REPO_DIR/skills/carbon-brain-search/SKILL.md" "$SKILLS_DIR/carbon-brain-search/SKILL.md"
  safe_execute cp "$REPO_DIR/skills/carbon-brain-context/SKILL.md" "$SKILLS_DIR/carbon-brain-context/SKILL.md"
  safe_execute cp "$REPO_DIR/skills/carbon-brain-plan/SKILL.md" "$SKILLS_DIR/carbon-brain-plan/SKILL.md"
  safe_execute cp "$REPO_DIR/skills/carbon-brain-learn/SKILL.md" "$SKILLS_DIR/carbon-brain-learn/SKILL.md"
  safe_execute cp "$REPO_DIR/skills/carbon-brain-error/SKILL.md" "$SKILLS_DIR/carbon-brain-error/SKILL.md"
  safe_execute cp "$REPO_DIR/skills/carbon-brain-search-patterns/SKILL.md" "$SKILLS_DIR/carbon-brain-search-patterns/SKILL.md"
  safe_execute cp "$REPO_DIR/skills/carbon-brain-setup/SKILL.md" "$SKILLS_DIR/carbon-brain-setup/SKILL.md"

  echo "✅ Skills instaladas (12 skills total)"

  # Register hooks in settings.json
  if [ "$MODE" = "manual" ]; then
    echo ""
    echo "📝 Registrando hooks no settings.json..."

    if [ "$DRY_RUN" = false ]; then
      register_hooks_in_settings
    else
      echo "[DRY-RUN] Registraria hooks no settings.json"
    fi
  fi

  # Create Obsidian templates
  echo ""
  echo "📄 Criando templates no Obsidian..."

  BRAIN_FOLDER="$OBSIDIAN_VAULT/_claude-brain"
  safe_execute mkdir -p "$BRAIN_FOLDER"
  safe_execute mkdir -p "$BRAIN_FOLDER/global/journals"

  if [ ! -f "$BRAIN_FOLDER/global/learnings.md" ]; then
    safe_execute cp "$REPO_DIR/templates/obsidian/learnings.md" "$BRAIN_FOLDER/global/"
    echo "✅ Template learnings.md criado"
  fi

  if [ ! -f "$BRAIN_FOLDER/global/errors-solved.md" ]; then
    safe_execute cp "$REPO_DIR/templates/obsidian/errors-solved.md" "$BRAIN_FOLDER/global/"
    echo "✅ Template errors-solved.md criado"
  fi

  if [ ! -f "$BRAIN_FOLDER/global/patterns.md" ]; then
    if [ -f "$REPO_DIR/templates/obsidian/patterns.md" ]; then
      safe_execute cp "$REPO_DIR/templates/obsidian/patterns.md" "$BRAIN_FOLDER/global/"
    else
      if [ "$DRY_RUN" = false ]; then
        cat > "$BRAIN_FOLDER/global/patterns.md" <<'EOF'
# Padrões Reutilizáveis

> Padrões de código e arquitetura que funcionam bem.
> Mantenha conciso com exemplos curtos.

---
*Atualizado automaticamente via carbon-claude-brain*
EOF
      fi
    fi
    echo "✅ Template patterns.md criado"
  fi

  # Success!
  print_success

  if [ "$DRY_RUN" = true ]; then
    echo ""
    echo "🔍 DRY-RUN COMPLETO - Nenhuma alteração foi feita"
    echo "   Execute sem --dry-run para instalar de verdade"
  fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HOOK REGISTRATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

register_hooks_in_settings() {
  local SETTINGS_FILE="$CLAUDE_DIR/settings.json"

  if [ ! -f "$SETTINGS_FILE" ]; then
    echo "{}" > "$SETTINGS_FILE"
  fi

  # Use Node.js to modify settings.json
  node -e "
const fs = require('fs');
const settings = JSON.parse(fs.readFileSync('$SETTINGS_FILE', 'utf8'));

settings.hooks = settings.hooks || {};
settings.hooks.PreToolUse = settings.hooks.PreToolUse || [];
settings.hooks.PostToolUse = settings.hooks.PostToolUse || [];
settings.hooks.Stop = settings.hooks.Stop || [];
settings.hooks.SessionEnd = settings.hooks.SessionEnd || [];

const startHook = { matcher: '', hooks: [{ type: 'command', command: '$HOOKS_DIR/carbon-brain-start.sh' }] };
const endHook = { matcher: '', hooks: [{ type: 'command', command: '$HOOKS_DIR/carbon-brain-end.sh' }] };
const postHook = { matcher: '', hooks: [{ type: 'command', command: '$HOOKS_DIR/carbon-brain-post-tool.sh' }] };

const autoSavePrompt = \`You are about to auto-save the session summary for carbon-claude-brain.

INSTRUCTIONS:
1. Read the session transcript file provided in the hook input (transcript_path)
2. Analyze the conversation and generate a concise session summary with:
   - **O que foi feito**: What was accomplished (bullet points)
   - **Erros e aprendizados**: Errors encountered and learnings (if any)
   - **Próximos passos**: Next steps or open items (checkbox list)

3. Save the summary by:
   a. Writing the markdown summary to a temp file: /tmp/brain-summary-\\\${Date.now()}.md
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

const sessionEndHook = {
  matcher: '',
  hooks: [{
    type: 'agent',
    prompt: autoSavePrompt,
    model: 'claude-haiku-4',
    timeout: 60000
  }]
};

// Remove old carbon-brain hooks
function removeOldCarbonBrainHooks(hooks) {
  return hooks.filter(h => {
    const hasCarbon = h.hooks && h.hooks.some(ch =>
      (ch.command && ch.command.includes('carbon-brain')) ||
      (ch.prompt && ch.prompt.includes('carbon-claude-brain'))
    );
    return !hasCarbon;
  });
}

settings.hooks.PreToolUse = removeOldCarbonBrainHooks(settings.hooks.PreToolUse);
settings.hooks.PostToolUse = removeOldCarbonBrainHooks(settings.hooks.PostToolUse);
settings.hooks.Stop = removeOldCarbonBrainHooks(settings.hooks.Stop);
settings.hooks.SessionEnd = removeOldCarbonBrainHooks(settings.hooks.SessionEnd);

// Add updated hooks
settings.hooks.PreToolUse.push(startHook);
settings.hooks.Stop.push(endHook);
settings.hooks.PostToolUse.push(postHook);
settings.hooks.SessionEnd.push(sessionEndHook);

fs.writeFileSync('$SETTINGS_FILE', JSON.stringify(settings, null, 2));
console.log('✅ Hooks registrados no settings.json');
"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# EXECUTE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

main "$@"
