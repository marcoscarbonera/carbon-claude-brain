#!/usr/bin/env bash
# Busca patterns/aprendizados no Inkdrop

# shellcheck source=/dev/null
source ~/.carbon-brain/config

SEARCH_TERM="$1"

if [ -z "$SEARCH_TERM" ]; then
  echo "❌ Uso: /brain-search-patterns \"termo de busca\""
  exit 1
fi

echo "🔍 Buscando '$SEARCH_TERM' nos aprendizados (Inkdrop)..."
echo ""

# Buscar notas no Inkdrop
# Filtra por tags: claude-pattern, claude-aprendizado, claude-erro-resolvido
RESPONSE=$(curl -s --max-time 5 \
  -u "$INKDROP_USER:$INKDROP_PASS" \
  "$INKDROP_URL/notes?keyword=$SEARCH_TERM&limit=20" 2>&1)

CURL_EXIT=$?

if [ $CURL_EXIT -ne 0 ]; then
  echo "❌ Erro ao conectar com Inkdrop"
  echo "   Verifique se o servidor local está ativo"
  exit 1
fi

# Parsear e filtrar resultados
RESULTS=$(echo "$RESPONSE" | node -e "
try {
  const data = JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8'));
  const items = data.items || [];

  // Filtrar apenas notas relevantes (patterns, aprendizados)
  const relevantTags = ['claude-pattern', 'claude-aprendizado', 'claude-erro-resolvido', 'claude-preferencia'];

  const filtered = items.filter(note => {
    const tags = note.tags || [];
    return tags.some(tag => relevantTags.includes(tag));
  });

  if (filtered.length === 0) {
    console.log('NO_RESULTS');
    process.exit(0);
  }

  // Formatar saída
  filtered.forEach((note, index) => {
    const tags = (note.tags || []).join(', #');
    const created = new Date(note.createdAt).toISOString().split('T')[0];
    const preview = (note.body || '').substring(0, 200).replace(/\n/g, ' ');

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📝 ' + note.title);
    console.log('   Tags: #' + tags);
    console.log('   Criado: ' + created);
    console.log('');
    console.log('   ' + preview + (note.body.length > 200 ? '...' : ''));
    console.log('');
  });

  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('✅ Encontrado ' + filtered.length + ' nota(s)');

} catch (e) {
  console.log('ERROR: ' + e.message);
  process.exit(1);
}
" 2>&1)

NODE_EXIT=$?

if [ "$NODE_EXIT" -ne 0 ]; then
  echo "❌ Erro ao processar resposta do Inkdrop"
  exit 1
fi

if [ "$RESULTS" = "NO_RESULTS" ]; then
  echo "❌ Nenhum aprendizado/pattern encontrado para '$SEARCH_TERM'"
  echo ""
  echo "💡 Dicas:"
  echo "   - Use tags: #claude-pattern, #claude-aprendizado"
  echo "   - Crie notas com esses padrões no Inkdrop"
  echo "   - Use /brain-search para buscar em projetos específicos"
else
  echo "$RESULTS"
fi

echo ""
