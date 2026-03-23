# brain-inkdrop-setup

**Objetivo:** Ajuda a configurar o Inkdrop descobrindo o ID do notebook onde as notas devem ser criadas.

**Quando usar:**
- Durante instalação inicial do carbon-claude-brain
- Quando quiser mudar o notebook de destino
- Para descobrir IDs de notebooks existentes

---

## Instruções

Execute os seguintes passos:

1. **Carregar configuração:**
   ```bash
   source ~/.claude/hooks/lib-carbon-brain.sh
   load_config
   ```

2. **Verificar se Inkdrop está configurado:**
   ```bash
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
