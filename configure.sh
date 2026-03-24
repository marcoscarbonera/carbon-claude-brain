#!/usr/bin/env bash
# carbon-claude-brain — configure.sh
# Wizard de configuração pós-instalação
# Execute após instalar via marketplace
#
# Modos de uso:
#   1. Interativo: Execute sem argumentos, responda às perguntas
#   2. Não-interativo: Crie um .env na raiz do plugin e execute

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧠 carbon-claude-brain — Configuração"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── Detectar diretório do script e arquivo .env ─────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ENV="$SCRIPT_DIR/.env"

# ── Detectar diretório de configuração ──────────────────────────────────────

if [ -n "$CLAUDE_PLUGIN_DATA" ]; then
  CONFIG_DIR="$CLAUDE_PLUGIN_DATA"
  echo "✅ Modo marketplace detectado"
  echo "   Configuração será salva em: $CONFIG_DIR"
else
  CONFIG_DIR="$HOME/.carbon-brain"
  echo "⚠️  Modo manual detectado"
  echo "   Configuração será salva em: $CONFIG_DIR"
fi

mkdir -p "$CONFIG_DIR"

# ── Verificar modo não-interativo ───────────────────────────────────────────

NON_INTERACTIVE=false
if [ -f "$SOURCE_ENV" ]; then
  echo "📄 Arquivo .env encontrado: $SOURCE_ENV"
  echo "   Usando modo não-interativo"
  NON_INTERACTIVE=true

  # Carregar variáveis do .env
  set -a
  source "$SOURCE_ENV"
  set +a
fi

echo ""

# ── 1. Obsidian Vault ───────────────────────────────────────────────────────

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📁 Passo 1/3: Obsidian Vault"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$NON_INTERACTIVE" = false ]; then
  echo "O carbon-claude-brain usa um vault local do Obsidian para"
  echo "armazenar contexto de projetos, decisões e aprendizados."
  echo ""
  echo "Dicas para encontrar seu vault:"
  echo "  - Abra o Obsidian"
  echo "  - Settings → Files & Links → Vault location"
  echo "  - Copie o caminho completo"
  echo ""

  # Tentar detectar vault automaticamente
  DETECTED_VAULT=""
  if [ -d "$HOME/Documents/Obsidian Vault" ]; then
    DETECTED_VAULT="$HOME/Documents/Obsidian Vault"
  elif [ -d "$HOME/Obsidian" ]; then
    DETECTED_VAULT="$HOME/Obsidian"
  fi

  if [ -n "$DETECTED_VAULT" ]; then
    echo "Vault detectado automaticamente: $DETECTED_VAULT"
    read -p "Usar este vault? [S/n]: " USE_DETECTED
    if [ "$USE_DETECTED" != "n" ] && [ "$USE_DETECTED" != "N" ]; then
      OBSIDIAN_VAULT="$DETECTED_VAULT"
    fi
  fi

  if [ -z "$OBSIDIAN_VAULT" ]; then
    read -p "Caminho do vault do Obsidian: " OBSIDIAN_VAULT
  fi
fi

# Validar que o diretório existe
if [ ! -d "$OBSIDIAN_VAULT" ]; then
  echo "❌ Erro: Diretório não encontrado: $OBSIDIAN_VAULT"
  exit 1
fi

echo "✅ Vault configurado: $OBSIDIAN_VAULT"
echo ""

# ── 2. Inkdrop (Opcional) ───────────────────────────────────────────────────

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📔 Passo 2/3: Inkdrop (Opcional)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Se não-interativo, usar valores do .env (podem estar vazios)
if [ "$NON_INTERACTIVE" = true ]; then
  # INKDROP_URL, INKDROP_USER, INKDROP_PASS já foram carregados do .env
  # Se INKDROP_URL estiver vazio, Inkdrop está desabilitado
  if [ -n "$INKDROP_URL" ]; then
    echo "✅ Inkdrop configurado (do arquivo .env)"
    echo "   URL: $INKDROP_URL"
    echo "   User: $INKDROP_USER"

    # Testar conexão
    if [ -n "$INKDROP_USER" ] && [ -n "$INKDROP_PASS" ]; then
      echo ""
      echo "Testando conexão com Inkdrop..."
      if curl -s --max-time 5 -u "$INKDROP_USER:$INKDROP_PASS" "$INKDROP_URL/notes?limit=1" | grep -q '"items"'; then
        echo "✅ Conexão com Inkdrop estabelecida"
      else
        echo "⚠️  Falha ao conectar com Inkdrop"
        echo "   Verifique se o plugin local-rest-api está instalado e ativo"
      fi
    fi
  else
    echo "⏭️  Inkdrop não configurado (apenas Obsidian)"
  fi
else
  # Modo interativo
  echo "O Inkdrop é opcional e usado para:"
  echo "  - Preferências pessoais que sincronizam entre máquinas"
  echo "  - Journals de sessão com sync"
  echo ""
  echo "Se você não usa Inkdrop, pode pular esta etapa."
  echo "O sistema funcionará apenas com Obsidian."
  echo ""

  read -p "Configurar Inkdrop? [s/N]: " CONFIGURE_INKDROP

  INKDROP_URL=""
  INKDROP_USER=""
  INKDROP_PASS=""
  INKDROP_NOTEBOOK_ID=""

  if [ "$CONFIGURE_INKDROP" = "s" ] || [ "$CONFIGURE_INKDROP" = "S" ]; then
    echo ""
    echo "Para habilitar a API local do Inkdrop:"
    echo "  1. Abra Inkdrop"
    echo "  2. Preferences → Plugins"
    echo "  3. Instale: local-rest-api"
    echo "  4. Configure uma senha local (diferente da senha cloud!)"
    echo ""

    read -p "URL do Inkdrop [http://localhost:19840]: " INKDROP_URL_INPUT
    INKDROP_URL="${INKDROP_URL_INPUT:-http://localhost:19840}"

    read -p "Usuário (geralmente seu email): " INKDROP_USER
    read -s -p "Senha da API local: " INKDROP_PASS
    echo ""

    # Testar conexão
    echo ""
    echo "Testando conexão com Inkdrop..."
    if curl -s --max-time 5 -u "$INKDROP_USER:$INKDROP_PASS" "$INKDROP_URL/notes?limit=1" | grep -q '"items"'; then
      echo "✅ Conexão com Inkdrop estabelecida"

      # Perguntar sobre notebook
      echo ""
      read -p "Configurar notebook de destino? [s/N]: " CONFIGURE_NOTEBOOK
      if [ "$CONFIGURE_NOTEBOOK" = "s" ] || [ "$CONFIGURE_NOTEBOOK" = "S" ]; then
        echo ""
        echo "Use /brain-inkdrop-setup para listar notebooks disponíveis"
        echo "e copiar o ID desejado."
        echo ""
        read -p "ID do notebook (ex: book:abc123) [deixe vazio para inbox]: " INKDROP_NOTEBOOK_ID
      fi
    else
      echo "❌ Falha ao conectar com Inkdrop"
      echo "   Verifique se o plugin local-rest-api está instalado e ativo"
      echo "   A configuração será salva, mas pode não funcionar"
    fi
  else
    echo "⏭️  Inkdrop não será configurado (apenas Obsidian)"
  fi
fi

echo ""

# ── 3. Salvar Configuração ──────────────────────────────────────────────────

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💾 Passo 3/3: Salvando Configuração"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ENV_FILE="$CONFIG_DIR/.env"

# Criar .env
cat > "$ENV_FILE" <<EOF
# carbon-claude-brain — Configuração
# Gerado em: $(date '+%Y-%m-%d %H:%M:%S')

# Obsidian vault (obrigatório)
OBSIDIAN_VAULT="$OBSIDIAN_VAULT"

# Inkdrop (opcional)
INKDROP_URL="$INKDROP_URL"
INKDROP_USER="$INKDROP_USER"
INKDROP_PASS="$INKDROP_PASS"
INKDROP_NOTEBOOK_ID="$INKDROP_NOTEBOOK_ID"
EOF

chmod 600 "$ENV_FILE"

echo "✅ Configuração salva em: $ENV_FILE"
echo ""

# ── 4. Criar Estrutura no Obsidian ──────────────────────────────────────────

echo "Criando estrutura de diretórios no Obsidian..."

BRAIN_DIR="$OBSIDIAN_VAULT/_claude-brain"
mkdir -p "$BRAIN_DIR/global/journals"
mkdir -p "$BRAIN_DIR/projects"

# Criar arquivos base se não existirem
if [ ! -f "$BRAIN_DIR/global/learnings.md" ]; then
  cat > "$BRAIN_DIR/global/learnings.md" <<'EOF'
# Aprendizados Gerais

> Este arquivo contém aprendizados reutilizáveis que se aplicam a múltiplos projetos.
> Use `/brain-learn` para adicionar novos aprendizados.

## Performance

## Segurança

## Arquitetura

## Testes
EOF
fi

if [ ! -f "$BRAIN_DIR/global/errors-solved.md" ]; then
  cat > "$BRAIN_DIR/global/errors-solved.md" <<'EOF'
# Erros Resolvidos

> Documentação de erros não-óbvios e suas soluções.
> Use `/brain-error` para adicionar novos erros.

EOF
fi

if [ ! -f "$BRAIN_DIR/global/patterns.md" ]; then
  cat > "$BRAIN_DIR/global/patterns.md" <<'EOF'
# Padrões Reutilizáveis

> Code patterns e soluções comuns documentadas.

EOF
fi

echo "✅ Estrutura criada em: $BRAIN_DIR"
echo ""

# ── Finalização ─────────────────────────────────────────────────────────────

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Configuração Concluída!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Próximos passos:"
echo ""
echo "  1. Teste a instalação:"
echo "     /brain-test"
echo ""
echo "  2. Veja o contexto carregado:"
echo "     /brain-context"
echo ""
echo "  3. Ao trabalhar em um projeto, o contexto será"
echo "     carregado automaticamente ao iniciar o Claude."
echo ""
echo "  4. Ao encerrar, salve resumo da sessão:"
echo "     /brain-save"
echo ""
echo "Documentação completa:"
echo "  https://github.com/marcoscarvalhodearaujo/carbon-claude-brain"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
