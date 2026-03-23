---
name: brain-search-patterns
description: >
  Busca aprendizados gerais e padrões no Inkdrop (conhecimento pessoal).
  Use para encontrar patterns reutilizáveis, não específicos de projeto.
---

# /brain-search-patterns — Busca em Conhecimento Pessoal

Busca aprendizados gerais, padrões e preferências no **Inkdrop** (conhecimento pessoal).

## O que busca

Busca em notas do Inkdrop com tags:
- `#claude-pattern` - Padrões de código reutilizáveis
- `#claude-aprendizado` - Aprendizados gerais
- `#claude-erro-resolvido` - Erros resolvidos
- `#claude-preferencia` - Preferências de desenvolvimento

## Como usar

```bash
/brain-search-patterns "error handling"
/brain-search-patterns "docker compose"
/brain-search-patterns "#react hooks"
```

## Implementação

```bash
#!/usr/bin/env bash
source ~/.claude/hooks/lib-carbon-brain.sh
load_config

SEARCH_TERM="$1"

if [ -z "$SEARCH_TERM" ]; then
  echo "❌ Uso: /brain-search-patterns \"termo de busca\""
  exit 1
fi

echo "🔍 Buscando '$SEARCH_TERM' nos aprendizados (Inkdrop)..."
echo ""

# Verificar se Inkdrop está habilitado
if ! is_inkdrop_enabled; then
  echo "ℹ️  Inkdrop não configurado"
  echo "   Esta skill busca no conhecimento pessoal do Inkdrop"
  echo "   Use /brain-search para buscar em projetos do Obsidian"
  exit 0
fi

# Buscar notas no Inkdrop
RESPONSE=$(curl -s --max-time 5 \
  -u "$INKDROP_USER:$INKDROP_PASS" \
  "$INKDROP_URL/notes?keyword=$SEARCH_TERM&limit=20" 2>&1)

CURL_EXIT=$?

if [ $CURL_EXIT -ne 0 ]; then
  echo "❌ Erro ao conectar com Inkdrop"
  echo "   Verifique se o servidor local está ativo:"
  echo "   Inkdrop → Preferences → Integrations → Local REST API Server"
  exit 1
fi

# Parsear e filtrar resultados
RESULTS=$(echo "$RESPONSE" | node -e "
try {
  const data = JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8'));
  const items = data.items || [];

  // Filtrar apenas notas relevantes
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
```

## Exemplo de output

```
🔍 Buscando 'react hooks' nos aprendizados (Inkdrop)...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📝 React Hooks — Melhores Práticas
   Tags: #claude-pattern, #react
   Criado: 2026-03-15

   Sempre usar useCallback para funções passadas como props.
   useMemo apenas para cálculos caros (>50ms). useEffect deve
   ter array de dependências completo...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📝 Custom Hook Pattern
   Tags: #claude-pattern, #react
   Criado: 2026-03-10

   Prefixar com 'use' (ex: useAuth, useFetch). Retornar
   objeto com estado e métodos. Manter single responsibility...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Encontrado 2 nota(s)
```

## Diferença de /brain-search

- `/brain-search` → Busca no **Obsidian** (projetos específicos)
- `/brain-search-patterns` → Busca no **Inkdrop** (aprendizados gerais)

### Quando usar cada um

**Use /brain-search quando:**
- Procurar como você implementou algo em projeto específico
- Buscar decisões técnicas de projetos passados
- Ver arquitetura de projetos similares

**Use /brain-search-patterns quando:**
- Procurar padrões de código reutilizáveis
- Lembrar de aprendizados gerais
- Buscar suas preferências pessoais
- Encontrar erros que você já resolveu antes

## Tags recomendadas no Inkdrop

### #claude-pattern
Padrões de código reutilizáveis

**Exemplos:**
- React Custom Hooks Pattern
- Error Handling Pattern
- Repository Pattern com TypeScript
- API Response Wrapper

### #claude-aprendizado
Aprendizados gerais sobre programação

**Exemplos:**
- Quando usar Map vs Object em JavaScript
- Docker multi-stage builds performance gains
- PostgreSQL indexing strategies

### #claude-erro-resolvido
Erros não óbvios que você já resolveu

**Exemplos:**
- Docker EACCES permission denied
- React useEffect infinite loop
- PostgreSQL deadlock detection

### #claude-preferencia
Suas preferências de desenvolvimento

**Exemplos:**
- Code style preferences
- Bibliotecas favoritas por caso de uso
- Stack tecnológica preferida

## Criar nota no Inkdrop

Para aproveitar ao máximo esta skill, crie notas estruturadas:

```markdown
Título: React Error Boundary Pattern

Tags: #claude-pattern #react #error-handling

# React Error Boundary Pattern

## Quando usar
- Envolver componentes que podem falhar
- Catch errors em renderização
- Mostrar fallback UI ao invés de crash

## Implementação

\`\`\`tsx
class ErrorBoundary extends React.Component {
  state = { hasError: false }

  static getDerivedStateFromError(error) {
    return { hasError: true }
  }

  componentDidCatch(error, info) {
    logErrorToService(error, info)
  }

  render() {
    if (this.state.hasError) {
      return <ErrorFallback />
    }
    return this.props.children
  }
}
\`\`\`

## Melhores práticas
- Uma boundary por feature, não global
- Logar erros para monitoramento
- Fallback com opção de retry
```

## Requisitos

- Inkdrop instalado com Local REST API Server ativo
- Configuração em `~/.carbon-brain/.env`:
  ```bash
  INKDROP_URL=http://localhost:19840
  INKDROP_USER=seu-email
  INKDROP_PASS=sua-senha-local
  ```

## Se Inkdrop não estiver configurado

A skill mostrará:

```
ℹ️  Inkdrop não configurado
   Esta skill busca no conhecimento pessoal do Inkdrop
   Use /brain-search para buscar em projetos do Obsidian
```

O sistema continua funcionando apenas com Obsidian.
