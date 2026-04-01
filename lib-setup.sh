#!/usr/bin/env bash
# lib-setup.sh - Shared setup functions for carbon-claude-brain
# Version: 1.0.0

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HEADER & UI FUNCTIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_header() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🧠 carbon-claude-brain — Instalação Inteligente"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
}

print_success() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✅ Instalação Concluída com Sucesso!"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "📋 Próximos passos:"
  echo "   • Reinicie o Claude Code"
  echo "   • Execute /carbon-brain-test para validar"
  echo "   • Explore: /carbon-brain para ver comandos disponíveis"
  echo ""
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEPENDENCY CHECKS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

check_dependencies() {
  echo "🔍 Verificando dependências..."

  local MISSING=()

  # Bash version
  if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    MISSING+=("bash ≥4.0 (atual: $BASH_VERSION)")
  fi

  # curl
  if ! command -v curl &> /dev/null; then
    MISSING+=("curl")
  fi

  # node
  if ! command -v node &> /dev/null; then
    MISSING+=("node ≥14.0")
  fi

  # Claude Code
  if [ ! -d "$HOME/.claude" ]; then
    MISSING+=("Claude Code (diretório ~/.claude não encontrado)")
  fi

  if [ ${#MISSING[@]} -gt 0 ]; then
    echo ""
    echo "❌ Dependências ausentes:"
    for dep in "${MISSING[@]}"; do
      echo "   • $dep"
    done
    echo ""
    echo "Instale as dependências e tente novamente."
    return 1
  fi

  echo "✅ Todas as dependências verificadas"
  return 0
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# OBSIDIAN VAULT AUTO-DETECTION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

detect_obsidian_vaults() {
  local OBSIDIAN_JSON="$HOME/Library/Application Support/obsidian/obsidian.json"
  local VAULTS=()

  # Method 1: Parse obsidian.json (PRIMARY)
  if [ -f "$OBSIDIAN_JSON" ]; then
    # Use Node.js to parse JSON and extract vaults
    local JSON_VAULTS
    JSON_VAULTS=$(node -e "
      try {
        const fs = require('fs');
        const data = JSON.parse(fs.readFileSync('$OBSIDIAN_JSON', 'utf8'));
        const vaults = data.vaults || {};

        // Convert to array and sort by: open > timestamp > name
        const sorted = Object.entries(vaults)
          .map(([id, v]) => ({
            id,
            path: v.path,
            ts: v.ts || 0,
            open: v.open || false
          }))
          .filter(v => v.path && fs.existsSync(v.path))
          .sort((a, b) => {
            // Prioritize open vaults
            if (a.open && !b.open) return -1;
            if (!a.open && b.open) return 1;
            // Then by timestamp (most recent first)
            return (b.ts || 0) - (a.ts || 0);
          });

        sorted.forEach(v => console.log(v.path + '|' + (v.open ? 'OPEN' : '')));
      } catch (e) {
        // Silent fail - will use fallback methods
      }
    " 2>/dev/null)

    if [ -n "$JSON_VAULTS" ]; then
      while IFS= read -r line; do
        VAULTS+=("$line")
      done <<< "$JSON_VAULTS"
    fi
  fi

  # Method 2: Search for .obsidian directories (FALLBACK)
  if [ ${#VAULTS[@]} -eq 0 ]; then
    while IFS= read -r obsidian_dir; do
      local vault_path
      vault_path=$(dirname "$obsidian_dir")
      if [ -d "$vault_path" ] && [ -w "$vault_path" ]; then
        VAULTS+=("$vault_path|")
      fi
    done < <(find "$HOME" -type d -name ".obsidian" -maxdepth 5 2>/dev/null)
  fi

  # Method 3: Check common paths (LAST RESORT)
  if [ ${#VAULTS[@]} -eq 0 ]; then
    local COMMON_PATHS=(
      "$HOME/Documents/Obsidian Vault"
      "$HOME/Obsidian"
      "$HOME/Documents/Obsidian"
    )

    for path in "${COMMON_PATHS[@]}"; do
      if [ -d "$path/.obsidian" ]; then
        VAULTS+=("$path|")
      fi
    done
  fi

  # Return vaults (one per line)
  printf '%s\n' "${VAULTS[@]}"
}

select_obsidian_vault() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📂 Seleção de Obsidian Vault"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Detect vaults
  local DETECTED
  DETECTED=$(detect_obsidian_vaults)

  if [ -z "$DETECTED" ]; then
    echo ""
    echo "⚠️  Nenhum vault detectado automaticamente"
    echo ""
    read -rp "📁 Caminho do vault do Obsidian: " OBSIDIAN_VAULT
    OBSIDIAN_VAULT="${OBSIDIAN_VAULT/#\~/$HOME}"
    return 0
  fi

  # Count vaults
  local VAULT_COUNT
  VAULT_COUNT=$(echo "$DETECTED" | wc -l | tr -d ' ')

  if [ "$VAULT_COUNT" -eq 1 ]; then
    # Single vault auto-detected
    local VAULT_PATH
    local IS_OPEN
    VAULT_PATH=$(echo "$DETECTED" | cut -d'|' -f1)
    IS_OPEN=$(echo "$DETECTED" | cut -d'|' -f2)

    local VAULT_NAME
    VAULT_NAME=$(basename "$VAULT_PATH")

    echo ""
    echo "✓ Vault detectado automaticamente:"
    echo ""
    if [ "$IS_OPEN" = "OPEN" ]; then
      echo "  📂 $VAULT_NAME ⭐ (aberto recentemente)"
    else
      echo "  📂 $VAULT_NAME"
    fi
    echo "  📍 $VAULT_PATH"
    echo ""

    read -rp "Usar este vault? [S/n]: " USE_DETECTED
    if [ "$USE_DETECTED" != "n" ] && [ "$USE_DETECTED" != "N" ]; then
      OBSIDIAN_VAULT="$VAULT_PATH"
      return 0
    fi

    # User declined - ask for manual entry
    read -rp "📁 Caminho do vault do Obsidian: " OBSIDIAN_VAULT
    OBSIDIAN_VAULT="${OBSIDIAN_VAULT/#\~/$HOME}"
    return 0
  fi

  # Multiple vaults - show selection menu
  echo ""
  echo "✓ $VAULT_COUNT vaults detectados:"
  echo ""

  local -a VAULT_PATHS=()
  local INDEX=1

  while IFS= read -r line; do
    local VAULT_PATH
    local IS_OPEN
    VAULT_PATH=$(echo "$line" | cut -d'|' -f1)
    IS_OPEN=$(echo "$line" | cut -d'|' -f2)

    VAULT_PATHS+=("$VAULT_PATH")

    local VAULT_NAME
    VAULT_NAME=$(basename "$VAULT_PATH")

    # Shorten path for display
    local DISPLAY_PATH
    if [[ "$VAULT_PATH" == *"/iCloud~"* ]]; then
      DISPLAY_PATH="...$(echo "$VAULT_PATH" | grep -o '/iCloud~.*')"
    elif [[ "$VAULT_PATH" == "$HOME"* ]]; then
      DISPLAY_PATH="~${VAULT_PATH#$HOME}"
    else
      DISPLAY_PATH="$VAULT_PATH"
    fi

    if [ "$IS_OPEN" = "OPEN" ]; then
      echo "  [$INDEX] 📂 $VAULT_NAME ⭐ (aberto)"
    else
      echo "  [$INDEX] 📂 $VAULT_NAME"
    fi
    echo "      📍 $DISPLAY_PATH"
    echo ""

    INDEX=$((INDEX + 1))
  done <<< "$DETECTED"

  echo "  [$INDEX] 📂 Informar manualmente"
  echo ""

  # Get user selection
  read -rp "Selecione [1-$INDEX] ou Enter para [1]: " SELECTION
  SELECTION=${SELECTION:-1}

  if [ "$SELECTION" -eq "$INDEX" ]; then
    # Manual entry
    read -rp "📁 Caminho do vault do Obsidian: " OBSIDIAN_VAULT
    OBSIDIAN_VAULT="${OBSIDIAN_VAULT/#\~/$HOME}"
  elif [ "$SELECTION" -ge 1 ] && [ "$SELECTION" -lt "$INDEX" ]; then
    # Valid selection
    OBSIDIAN_VAULT="${VAULT_PATHS[$((SELECTION-1))]}"
  else
    echo "❌ Seleção inválida"
    return 1
  fi

  return 0
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PRE-FLIGHT VALIDATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

validate_configuration() {
  local VAULT="$1"
  local INKDROP_URL="$2"
  local INKDROP_USER="$3"
  local INKDROP_PASS="$4"

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔍 Validação Pré-Instalação"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  local ERRORS=()
  local WARNINGS=()

  # 1. Vault exists and writable
  echo -n "Validando vault Obsidian... "
  if [ ! -d "$VAULT" ]; then
    ERRORS+=("Vault não existe: $VAULT")
    echo "❌"
  elif [ ! -w "$VAULT" ]; then
    ERRORS+=("Vault sem permissão de escrita: $VAULT")
    echo "❌"
  elif [ ! -d "$VAULT/.obsidian" ]; then
    WARNINGS+=("Diretório .obsidian não encontrado - pode não ser vault válido")
    echo "⚠️"
  else
    echo "✓"
  fi

  # 2. Disk space (need 1MB for templates)
  echo -n "Verificando espaço em disco... "
  local AVAILABLE_KB
  AVAILABLE_KB=$(df -k "$VAULT" 2>/dev/null | awk 'NR==2 {print $4}')
  if [ -z "$AVAILABLE_KB" ] || [ "$AVAILABLE_KB" -lt 1024 ]; then
    ERRORS+=("Espaço insuficiente (precisa de pelo menos 1MB)")
    echo "❌"
  else
    echo "✓"
  fi

  # 3. Claude Code writable
  echo -n "Validando Claude Code... "
  if [ ! -w "$HOME/.claude" ]; then
    ERRORS+=("~/.claude sem permissão de escrita")
    echo "❌"
  else
    echo "✓"
  fi

  # 4. settings.json is valid JSON
  if [ -f "$HOME/.claude/settings.json" ]; then
    echo -n "Validando settings.json... "
    if node -e "JSON.parse(require('fs').readFileSync('$HOME/.claude/settings.json'))" 2>/dev/null; then
      echo "✓"
    else
      ERRORS+=("settings.json é JSON inválido")
      echo "❌"
    fi
  fi

  # 5. Check existing installation
  echo -n "Verificando instalação existente... "
  if [ -f "$HOME/.carbon-brain/.env" ] || [ -f "$HOME/.carbon-brain/config" ]; then
    WARNINGS+=("Configuração existente será preservada/migrada")
    echo "⚠️"
  else
    echo "✓"
  fi

  # 6. Inkdrop connection (if configured)
  if [ -n "$INKDROP_URL" ]; then
    echo -n "Testando Inkdrop... "
    if curl -s --max-time 3 -u "$INKDROP_USER:$INKDROP_PASS" \
            "$INKDROP_URL/notes?limit=1" 2>/dev/null | grep -q '"items"'; then
      echo "✓"
    else
      WARNINGS+=("Inkdrop configurado mas conexão falhou (opcional)")
      echo "⚠️"
    fi
  fi

  echo ""

  # Report results
  if [ ${#ERRORS[@]} -gt 0 ]; then
    echo "❌ ERROS CRÍTICOS:"
    for err in "${ERRORS[@]}"; do
      echo "  • $err"
    done
    echo ""
    echo "A instalação não pode continuar."
    return 1
  fi

  if [ ${#WARNINGS[@]} -gt 0 ]; then
    echo "⚠️  AVISOS:"
    for warn in "${WARNINGS[@]}"; do
      echo "  • $warn"
    done
    echo ""
    read -rp "Continuar mesmo assim? [S/n]: " CONTINUE
    [ "$CONTINUE" = "n" ] || [ "$CONTINUE" = "N" ] && return 1
  else
    echo "✓ Validação concluída! Pronto para instalar."
  fi

  echo ""
  return 0
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# INKDROP WIZARD
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

setup_inkdrop_wizard() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔧 Configuração Inkdrop — Guia Interativo"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # STEP 1: Check if Inkdrop is running
  echo ""
  echo "Passo 1/4: Verificando se Inkdrop está rodando..."

  INKDROP_URL="http://localhost:19840"

  if curl -s --max-time 2 "$INKDROP_URL" &>/dev/null; then
    echo "✓ Inkdrop detectado em localhost:19840"
  else
    echo "⚠️  Inkdrop não está rodando"
    echo ""
    echo "📖 Para habilitar a API local:"
    echo "   1. Abra Inkdrop"
    echo "   2. Preferences → Plugins"
    echo "   3. Busque 'local-rest-api'"
    echo "   4. Clique Install → Enable"
    echo "   5. Configure senha local (DIFERENTE da senha cloud!)"
    echo ""

    read -rp "Pular Inkdrop e continuar apenas com Obsidian? [S/n]: " SKIP
    if [ "$SKIP" != "n" ] && [ "$SKIP" != "N" ]; then
      INKDROP_URL=""
      INKDROP_USER=""
      INKDROP_PASS=""
      INKDROP_NOTEBOOK_ID=""
      return 0
    fi

    echo ""
    read -rp "Pressione Enter quando estiver pronto..."
  fi

  # STEP 2: Get credentials
  echo ""
  echo "Passo 2/4: Credenciais"
  read -rp "Email/usuário: " INKDROP_USER
  read -srp "Senha da API local: " INKDROP_PASS
  echo ""

  # STEP 3: Test connection with retry
  echo ""
  echo "Passo 3/4: Testando conexão..."

  local CONNECTION_OK=false

  for attempt in 1 2 3; do
    if curl -s --max-time 5 -u "$INKDROP_USER:$INKDROP_PASS" \
         "$INKDROP_URL/notes?limit=1" 2>/dev/null | grep -q '"items"'; then
      echo "✓ Conexão estabelecida!"
      CONNECTION_OK=true
      break
    else
      echo "✗ Tentativa $attempt/3 falhou"

      if [ $attempt -lt 3 ]; then
        echo ""
        echo "💡 Dicas:"
        echo "   • Verifique se é a senha da API LOCAL (não cloud)"
        echo "   • Confirme que o plugin está ativo (verde)"
        echo "   • Reinicie o Inkdrop se necessário"
        echo ""
        read -rp "Tentar novamente? [S/n]: " RETRY
        if [ "$RETRY" = "n" ] || [ "$RETRY" = "N" ]; then
          break
        fi

        # Re-ask for credentials
        read -rp "Email/usuário: " INKDROP_USER
        read -srp "Senha da API local: " INKDROP_PASS
        echo ""
      fi
    fi
  done

  if [ "$CONNECTION_OK" != true ]; then
    echo ""
    echo "❌ Não foi possível conectar"
    read -rp "Pular Inkdrop e continuar apenas com Obsidian? [S/n]: " SKIP
    if [ "$SKIP" != "n" ] && [ "$SKIP" != "N" ]; then
      INKDROP_URL=""
      INKDROP_USER=""
      INKDROP_PASS=""
      INKDROP_NOTEBOOK_ID=""
      return 0
    else
      return 1
    fi
  fi

  # STEP 4: Notebook selection (visual list)
  echo ""
  echo "Passo 4/4: Notebook de destino (opcional)"
  echo ""

  local NOTEBOOKS
  NOTEBOOKS=$(curl -s -u "$INKDROP_USER:$INKDROP_PASS" "$INKDROP_URL/books" 2>/dev/null)

  if [ -z "$NOTEBOOKS" ]; then
    echo "⚠️  Não foi possível listar notebooks"
    INKDROP_NOTEBOOK_ID=""
    return 0
  fi

  # Parse and display notebooks
  echo "$NOTEBOOKS" | node -e "
    try {
      const data = JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8'));
      const books = data.items || [];

      if (books.length === 0) {
        console.log('Nenhum notebook encontrado. Usando inbox.');
        process.exit(0);
      }

      console.log('📚 Notebooks disponíveis:\n');

      books.forEach((book, i) => {
        const indent = book.parentBookId ? '  ' : '';
        console.log(\`  [\${i+1}] \${indent}📁 \${book.name}\`);
      });

      console.log('\\n  [0] Usar inbox (sem notebook específico)');
    } catch (e) {
      console.log('Erro ao processar notebooks');
    }
  " 2>/dev/null

  echo ""
  read -rp "Selecione [0-N] ou Enter para inbox: " NOTEBOOK_CHOICE
  NOTEBOOK_CHOICE=${NOTEBOOK_CHOICE:-0}

  if [ "$NOTEBOOK_CHOICE" != "0" ]; then
    INKDROP_NOTEBOOK_ID=$(echo "$NOTEBOOKS" | node -e "
      try {
        const data = JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8'));
        const choice = parseInt(process.argv[1]) - 1;
        console.log(data.items[choice]?._id || '');
      } catch (e) {
        console.log('');
      }
    " "$NOTEBOOK_CHOICE" 2>/dev/null)

    if [ -n "$INKDROP_NOTEBOOK_ID" ]; then
      echo "✓ Notebook selecionado: $INKDROP_NOTEBOOK_ID"
    else
      echo "⚠️  Seleção inválida, usando inbox"
      INKDROP_NOTEBOOK_ID=""
    fi
  else
    INKDROP_NOTEBOOK_ID=""
  fi

  return 0
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BACKUP FUNCTIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

backup_existing_config() {
  local CONFIG_DIR="$1"

  if [ -f "$CONFIG_DIR/.env" ]; then
    local BACKUP_FILE="$CONFIG_DIR/.env.backup.$(date +%Y%m%d-%H%M%S)"
    cp "$CONFIG_DIR/.env" "$BACKUP_FILE"
    echo "✓ Backup criado: $BACKUP_FILE"
  fi

  if [ -f "$CONFIG_DIR/config" ]; then
    local BACKUP_FILE="$CONFIG_DIR/config.backup.$(date +%Y%m%d-%H%M%S)"
    cp "$CONFIG_DIR/config" "$BACKUP_FILE"
    echo "✓ Backup criado: $BACKUP_FILE"
  fi
}
