#!/usr/bin/env bash
# carbon-claude-brain — install.sh
# Configura hooks e skills no Claude Code

set -e

CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SKILLS_DIR="$CLAUDE_DIR/skills"
CONFIG_FILE="$HOME/.carbon-brain/config"

echo ""
echo "🧠 carbon-claude-brain — instalação"
echo "======================================"
echo ""

# ── Verificar dependências ─────────────────────────────────────────────────

echo "🔍 Verificando dependências..."

# Verificar bash version (precisa ≥4.0)
BASH_VERSION_MAJOR="${BASH_VERSINFO[0]}"
if [ "$BASH_VERSION_MAJOR" -lt 4 ]; then
  echo "❌ Erro: bash versão 4.0 ou superior é necessário"
  echo "   Versão atual: $BASH_VERSION"
  exit 1
fi

# Verificar curl
if ! command -v curl &> /dev/null; then
  echo "❌ Erro: curl não está instalado"
  echo "   Instale com: brew install curl (macOS) ou apt-get install curl (Linux)"
  exit 1
fi

# Verificar node (necessário para parsing JSON)
if ! command -v node &> /dev/null; then
  echo "❌ Erro: node não está instalado"
  echo "   Instale com: brew install node (macOS) ou apt-get install nodejs (Linux)"
  echo "   Nota: node é necessário para manipular o settings.json do Claude Code"
  exit 1
fi

# Verificar se Claude Code está instalado
if [ ! -d "$CLAUDE_DIR" ]; then
  echo "❌ Erro: Claude Code não parece estar instalado"
  echo "   Diretório não encontrado: $CLAUDE_DIR"
  echo "   Instale Claude Code primeiro: https://claude.ai/claude-code"
  exit 1
fi

echo "✅ Todas as dependências verificadas"
echo ""

# ── Coletar configurações ──────────────────────────────────────────────────

read -rp "📁 Caminho do vault do Obsidian (ex: ~/Documents/MyVault): " OBSIDIAN_VAULT
OBSIDIAN_VAULT="${OBSIDIAN_VAULT/#\~/$HOME}"

if [ ! -d "$OBSIDIAN_VAULT" ]; then
  echo "❌ Vault não encontrado: $OBSIDIAN_VAULT"
  exit 1
fi

echo ""
echo "Inkdrop é OPCIONAL. Deixe vazio para desabilitar."
echo ""

read -rp "🔗 URL do servidor Inkdrop [deixe vazio para desabilitar]: " INKDROP_URL
INKDROP_URL="${INKDROP_URL:-}"

if [ -n "$INKDROP_URL" ]; then
  read -rp "👤 Usuário do Inkdrop local: " INKDROP_USER
  read -rsp "🔑 Senha do Inkdrop local: " INKDROP_PASS
  echo ""
else
  INKDROP_USER=""
  INKDROP_PASS=""
  echo "⚠️  Inkdrop desabilitado. Apenas Obsidian será usado."
fi

# ── Criar diretórios ───────────────────────────────────────────────────────

mkdir -p "$HOME/.carbon-brain"
mkdir -p "$HOOKS_DIR"
mkdir -p "$SKILLS_DIR/brain"
mkdir -p "$SKILLS_DIR/obsidian"
mkdir -p "$SKILLS_DIR/inkdrop"

# ── Salvar configuração ────────────────────────────────────────────────────

# Criar arquivo .env (padrão universal)
ENV_FILE="$HOME/.carbon-brain/.env"

cat > "$ENV_FILE" <<EOF
# carbon-claude-brain configuration
# DO NOT COMMIT THIS FILE

OBSIDIAN_VAULT="$OBSIDIAN_VAULT"
INKDROP_URL="$INKDROP_URL"
INKDROP_USER="$INKDROP_USER"
INKDROP_PASS="$INKDROP_PASS"
EOF
chmod 600 "$ENV_FILE"

echo "✅ Configuração salva em ~/.carbon-brain/.env"

# Criar também config antigo para compatibilidade retroativa
cat > "$CONFIG_FILE" <<EOF
# DEPRECATED: Use .env instead
# This file is kept for backwards compatibility only

OBSIDIAN_VAULT="$OBSIDIAN_VAULT"
INKDROP_URL="$INKDROP_URL"
INKDROP_USER="$INKDROP_USER"
INKDROP_PASS="$INKDROP_PASS"
EOF
chmod 600 "$CONFIG_FILE"

# ── Instalar hooks ─────────────────────────────────────────────────────────

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Copiar biblioteca compartilhada
cp "$REPO_DIR/hooks/lib-carbon-brain.sh" "$HOOKS_DIR/lib-carbon-brain.sh"
chmod +x "$HOOKS_DIR/lib-carbon-brain.sh"

# Copiar hooks
cp "$REPO_DIR/hooks/session-start.sh"    "$HOOKS_DIR/carbon-brain-start.sh"
cp "$REPO_DIR/hooks/session-end.sh"      "$HOOKS_DIR/carbon-brain-end.sh"
cp "$REPO_DIR/hooks/post-tool-use.sh"    "$HOOKS_DIR/carbon-brain-post-tool.sh"
cp "$REPO_DIR/hooks/auto-save-helper.sh" "$HOOKS_DIR/auto-save-helper.sh"

chmod +x "$HOOKS_DIR/carbon-brain-start.sh"
chmod +x "$HOOKS_DIR/carbon-brain-end.sh"
chmod +x "$HOOKS_DIR/carbon-brain-post-tool.sh"
chmod +x "$HOOKS_DIR/auto-save-helper.sh"

echo "✅ Hooks instalados em ~/.claude/hooks/"

# ── Instalar skills ────────────────────────────────────────────────────────

cp "$REPO_DIR/skills/brain/SKILL.md"    "$SKILLS_DIR/brain/SKILL.md"
cp "$REPO_DIR/skills/obsidian/SKILL.md" "$SKILLS_DIR/obsidian/SKILL.md"
cp "$REPO_DIR/skills/inkdrop/SKILL.md"  "$SKILLS_DIR/inkdrop/SKILL.md"

echo "✅ Skills instaladas em ~/.claude/skills/"

# ── Registrar hooks no settings.json ──────────────────────────────────────

SETTINGS_FILE="$CLAUDE_DIR/settings.json"

if [ ! -f "$SETTINGS_FILE" ]; then
  echo "{}" > "$SETTINGS_FILE"
fi

# Injetar hooks usando node (disponível se Claude Code está instalado)
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

// Hook SessionEnd com agent para auto-save inteligente
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

// Evitar duplicatas
const alreadyHasStart = JSON.stringify(settings).includes('carbon-brain-start');
if (!alreadyHasStart) {
  settings.hooks.PreToolUse.push(startHook);
  settings.hooks.Stop.push(endHook);
  settings.hooks.PostToolUse.push(postHook);
  settings.hooks.SessionEnd.push(sessionEndHook);
}

fs.writeFileSync('$SETTINGS_FILE', JSON.stringify(settings, null, 2));
console.log('Hooks registrados no settings.json (incluindo auto-save SessionEnd)');
"

# ── Templates do Obsidian ──────────────────────────────────────────────────

BRAIN_FOLDER="$OBSIDIAN_VAULT/_claude-brain"
mkdir -p "$BRAIN_FOLDER"
mkdir -p "$BRAIN_FOLDER/global/journals"

if [ ! -f "$BRAIN_FOLDER/project-context.md" ]; then
  cp "$REPO_DIR/templates/obsidian/project-context.md" "$BRAIN_FOLDER/"
  cp "$REPO_DIR/templates/obsidian/decision-log.md"    "$BRAIN_FOLDER/"
  cp "$REPO_DIR/templates/obsidian/architecture.md"    "$BRAIN_FOLDER/"
  echo "✅ Templates do Obsidian criados em $BRAIN_FOLDER"
fi

# Criar templates globais (se não existirem)
if [ ! -f "$BRAIN_FOLDER/global/learnings.md" ]; then
  cp "$REPO_DIR/templates/obsidian/learnings.md" "$BRAIN_FOLDER/global/"
  echo "✅ Template learnings.md criado em $BRAIN_FOLDER/global/"
fi

if [ ! -f "$BRAIN_FOLDER/global/errors-solved.md" ]; then
  cp "$REPO_DIR/templates/obsidian/errors-solved.md" "$BRAIN_FOLDER/global/"
  echo "✅ Template errors-solved.md criado em $BRAIN_FOLDER/global/"
fi

# Criar patterns.md se não existir
if [ ! -f "$BRAIN_FOLDER/global/patterns.md" ]; then
  cp "$REPO_DIR/templates/obsidian/patterns.md" "$BRAIN_FOLDER/global/" 2>/dev/null || cat > "$BRAIN_FOLDER/global/patterns.md" <<'EOF'
# Padrões Reutilizáveis

> Padrões de código e arquitetura que funcionam bem.
> Mantenha conciso com exemplos curtos.

---
*Atualizado automaticamente via carbon-claude-brain*
EOF
  echo "✅ Template patterns.md criado em $BRAIN_FOLDER/global/"
fi

echo ""
echo "🎉 Instalação concluída!"
echo ""
echo "   Próximo passo: edite os templates em:"
echo "   $BRAIN_FOLDER"
echo ""
echo "   E reinicie o Claude Code."
echo ""
