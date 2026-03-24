---
name: carbon-brain-setup
description: >
  Wizard de configuração completo do carbon-claude-brain.
  Use após instalar via marketplace para configurar Obsidian e Inkdrop.
  Também pode ser usado para reconfigurar ou listar notebooks do Inkdrop.
---

# /carbon-brain-setup — Configuração Completa

**Objetivo:** Configurar carbon-claude-brain após instalação via marketplace ou reconfigurar instalação existente.

**Quando usar:**
- ✅ **Primeira vez após `/plugin install`** (configuração inicial obrigatória)
- ✅ Quando quiser reconfigurar Obsidian vault ou Inkdrop
- ✅ Para descobrir IDs de notebooks do Inkdrop

## Uso Rápido

```bash
# Executar o wizard de configuração
bash "$CLAUDE_PLUGIN_ROOT/configure.sh"

# OU, se instalado manualmente (sem marketplace):
bash ~/.claude/hooks/../install.sh  # Use install.sh para instalação manual completa
```

## O que o wizard faz

1. **Detecta modo de instalação** (marketplace vs manual)
2. **Configura Obsidian vault**
   - Pede caminho do vault ou detecta automaticamente
   - Cria estrutura de diretórios `_claude-brain/`
3. **Configura Inkdrop** (opcional)
   - API URL, usuário e senha
   - Lista notebooks disponíveis
   - Configura `INKDROP_NOTEBOOK_ID`
4. **Salva configuração** no local correto:
   - Marketplace: `$CLAUDE_PLUGIN_DATA/.env`
   - Manual: `~/.carbon-brain/.env`

## Modo Não-Interativo

Se você criar um arquivo `.env` na raiz do plugin antes de rodar, o wizard usará essas configurações:

```bash
# Criar .env (no diretório do plugin para marketplace)
cat > "$CLAUDE_PLUGIN_ROOT/.env" <<EOF
OBSIDIAN_VAULT="/Users/seu-nome/Documents/ObsidianVault"
INKDROP_URL="http://localhost:19840"
INKDROP_USER="seu_usuario"
INKDROP_PASS="sua_senha"
INKDROP_NOTEBOOK_ID=""
EOF

# Executar wizard (não fará perguntas, usará .env)
bash "$CLAUDE_PLUGIN_ROOT/configure.sh"
```

## Apenas Listar Notebooks do Inkdrop

Se você já configurou e só quer ver os notebooks disponíveis:

```bash
source ~/.claude/hooks/lib-carbon-brain.sh
load_config

if ! is_inkdrop_enabled; then
  echo "❌ Inkdrop não está configurado."
     echo "Configure primeiro com: ./install.sh"
     exit 1
   fi
   ```

3. **Listar todos os notebooks:**
   ```bash
   curl -s -u "$INKDROP_USER:$INKDROP_PASS" \
     "$INKDROP_URL/books" | \
   node -e "
     const data = JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8'));

     if (data.error) {
       console.error('Erro da API:', data.error);
       process.exit(1);
     }

     const books = data.items || [];

     if (books.length === 0) {
       console.log('Nenhum notebook encontrado.');
       process.exit(0);
     }

     // Organizar hierarquia
     const rootBooks = books.filter(b => !b.parentBookId);
     const childBooks = books.filter(b => b.parentBookId);

     console.log('📚 Notebooks disponíveis:\n');

     // Mostrar raiz
     rootBooks.forEach(book => {
       console.log(\`📁 \${book.name}\`);
       console.log(\`   ID: \${book._id}\`);
       console.log('');

       // Mostrar filhos
       const children = childBooks.filter(c => c.parentBookId === book._id);
       children.forEach(child => {
         console.log(\`   📂 \${child.name}\`);
         console.log(\`      ID: \${child._id}\`);
         console.log('');
       });
     });

     // Mostrar órfãos (caso existam)
     const orphans = childBooks.filter(c => !books.find(b => b._id === c.parentBookId));
     if (orphans.length > 0) {
       console.log('⚠️  Notebooks órfãos (sem parent):');
       orphans.forEach(book => {
         console.log(\`📁 \${book.name}\`);
         console.log(\`   ID: \${book._id}\`);
         console.log('');
       });
     }
   "
   ```

4. **Explicar próximo passo:**
   ```bash
   echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
   echo ""
   echo "Para usar um notebook, copie o ID e adicione ao .env:"
   echo ""
   echo "  nano ~/.carbon-brain/.env"
   echo ""
   echo "Adicione a linha:"
   echo "  INKDROP_NOTEBOOK_ID=\"book:seu-id-aqui\""
   echo ""
   echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
   ```

5. **Opcional - Testar se ID configurado está válido:**
   ```bash
   if [ -n "$INKDROP_NOTEBOOK_ID" ]; then
     echo ""
     echo "✅ Notebook atual configurado: $INKDROP_NOTEBOOK_ID"
     echo ""

     # Verificar se existe
     curl -s -u "$INKDROP_USER:$INKDROP_PASS" \
       "$INKDROP_URL/books/$INKDROP_NOTEBOOK_ID" | \
     node -e "
       const data = JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8'));
       if (data._id) {
         console.log('   Nome:', data.name);
         console.log('   Status: ✅ Válido');
       } else {
         console.log('   Status: ❌ Não encontrado (ID inválido)');
       }
     "
   else
     echo ""
     echo "⚠️  Nenhum notebook configurado (notas vão para inbox)"
   fi
   ```

---

## Exemplo de output

```
📚 Notebooks disponíveis:

📁 Personal
   ID: book:abc123

   📂 Claude Brain
      ID: book:def456

📁 Work
   ID: book:ghi789

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Para usar um notebook, copie o ID e adicione ao .env:

  nano ~/.carbon-brain/.env

Adicione a linha:
  INKDROP_NOTEBOOK_ID="book:seu-id-aqui"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Notebook atual configurado: book:def456
   Nome: Claude Brain
   Status: ✅ Válido
```

---

## Notas

- Os IDs começam com `book:` seguido de hash alfanumérico
- Notebooks podem ter sub-notebooks (hierarquia ilimitada)
- Se não configurar `INKDROP_NOTEBOOK_ID`, as notas vão para a inbox
- Tags (`#claude-journal`, `#claude-preferencia`) são sempre adicionadas
