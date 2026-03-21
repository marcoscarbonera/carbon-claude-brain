---
name: brain
description: >
  Skill principal do carbon-claude-brain. Orquestra memória persistente
  usando Obsidian como segundo cérebro do projeto e Inkdrop como journal.
  Use quando o usuário mencionar "brain", "memória", "salvar sessão",
  "contexto do projeto", ou quando a sessão estiver encerrando.
---

# carbon-claude-brain

Você tem acesso a um sistema de memória persistente com duas camadas:

## 🗂️ Obsidian — Segundo Cérebro do Projeto
Vault local no filesystem. Use para:
- Planos de implementação e arquitetura
- Log de decisões técnicas importantes
- Contexto duradouro do projeto
- Documentação viva

**Leia via:** `cat "$OBSIDIAN_VAULT/_claude-brain/projects/$PROJECT/arquivo.md"`
**Escreva via:** redirecionamento bash direto para o arquivo `.md`

## 📔 Inkdrop — Journal do Claude
API HTTP local na porta 19840. Use para:
- Resumo de cada sessão de trabalho
- Aprendizados e erros cometidos
- Notas rápidas e observações
- Histórico acessível em qualquer máquina

**Credenciais:** leia de `~/.carbon-brain/config`

## Comandos disponíveis

### /brain-save
Salva o resumo da sessão atual. Execute ao encerrar:

1. **Obsidian** — Atualize `_claude-brain/projects/$PROJECT/decision-log.md` com decisões tomadas
2. **Inkdrop** — Crie uma nota de journal com:
   - Título: `Journal $PROJECT — YYYY-MM-DD`
   - Tag: `claude-journal`
   - Corpo: resumo do que foi feito, erros encontrados, próximos passos

```bash
# Ler config
source ~/.carbon-brain/config

# Criar nota no Inkdrop
curl -s -u "$INKDROP_USER:$INKDROP_PASS" \
  -X POST "$INKDROP_URL/notes" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Journal PROJETO — DATA",
    "body": "## O que foi feito\n...\n\n## Aprendizados\n...\n\n## Próximos passos\n...",
    "tags": ["claude-journal"]
  }'
```

### /brain-context
Mostra o contexto atual carregado do Obsidian para o projeto.

### /brain-plan
Cria ou atualiza o plano do projeto no Obsidian em:
`_claude-brain/projects/$PROJECT/project-context.md`

### /brain-search
Busca um termo em todos os projetos do Obsidian vault. Útil para encontrar soluções ou decisões passadas.

**Uso:**
```bash
/brain-search "authentication"
/brain-search "rate limiting redis"
/brain-search "docker compose"
```

**Implementação:**
```bash
#!/usr/bin/env bash
# Busca cross-project no Obsidian

source ~/.carbon-brain/config

SEARCH_TERM="$1"

if [ -z "$SEARCH_TERM" ]; then
  echo "❌ Uso: /brain-search \"termo de busca\""
  exit 1
fi

echo "🔍 Buscando '$SEARCH_TERM' em todos os projetos..."
echo ""

PROJECTS_DIR="$OBSIDIAN_VAULT/_claude-brain/projects"

if [ ! -d "$PROJECTS_DIR" ]; then
  echo "❌ Nenhum projeto encontrado em $PROJECTS_DIR"
  exit 1
fi

RESULTS_FOUND=0

# Buscar em cada projeto
for project_path in "$PROJECTS_DIR"/*; do
  if [ ! -d "$project_path" ]; then
    continue
  fi

  project_name=$(basename "$project_path")

  # Buscar em todos os .md do projeto (case insensitive)
  matches=$(grep -riHn --color=never "$SEARCH_TERM" "$project_path"/*.md 2>/dev/null)

  if [ -n "$matches" ]; then
    RESULTS_FOUND=$((RESULTS_FOUND + 1))

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📁 Projeto: $project_name"
    echo ""

    # Processar cada match
    while IFS= read -r line; do
      # Extrair: arquivo:linha:conteudo
      file=$(echo "$line" | cut -d: -f1)
      line_num=$(echo "$line" | cut -d: -f2)
      content=$(echo "$line" | cut -d: -f3-)

      file_name=$(basename "$file")

      echo "  📄 $file_name:$line_num"
      echo "     $content"
      echo ""
    done <<< "$matches"
  fi
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$RESULTS_FOUND" -eq 0 ]; then
  echo "❌ Nenhum resultado encontrado para '$SEARCH_TERM'"
  echo ""
  echo "💡 Dicas:"
  echo "   - Tente termos mais genéricos"
  echo "   - Verifique a ortografia"
  echo "   - Use /brain-context para ver o projeto atual"
else
  echo "✅ Encontrado em $RESULTS_FOUND projeto(s)"
fi

echo ""
```

**Casos de uso:**
- Lembrar como você resolveu um problema similar em outro projeto
- Encontrar decisões técnicas relacionadas a uma tecnologia
- Ver padrões que você usa em múltiplos projetos
- Descobrir aprendizados passados sobre um tema

### /brain-search-patterns
Busca aprendizados gerais e padrões no Inkdrop (não específicos de projeto).

**Uso:**
```bash
/brain-search-patterns "error handling"
/brain-search-patterns "docker compose"
/brain-search-patterns "#react hooks"
```

**Implementação:**
```bash
#!/usr/bin/env bash
# Busca patterns/aprendizados no Inkdrop

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
```

**Diferença de /brain-search:**
- `/brain-search` → Busca no **Obsidian** (contexto de projetos específicos)
- `/brain-search-patterns` → Busca no **Inkdrop** (aprendizados gerais, padrões reutilizáveis)

**Tags recomendadas no Inkdrop:**
- `#claude-pattern` → Padrões de código reutilizáveis
- `#claude-aprendizado` → Aprendizados gerais
- `#claude-erro-resolvido` → Erros resolvidos (para não repetir)
- `#claude-preferencia` → Suas preferências de desenvolvimento

### /brain-test
Verifica se o carbon-claude-brain está configurado corretamente. Execute este comando para diagnosticar problemas.

```bash
#!/usr/bin/env bash
# Diagnóstico do carbon-claude-brain

echo "🧠 carbon-claude-brain — Diagnóstico"
echo "======================================"
echo ""

# Ler config
CONFIG="$HOME/.carbon-brain/config"
if [ ! -f "$CONFIG" ]; then
  echo "❌ Config não encontrado: $CONFIG"
  echo "   Execute: ./install.sh"
  exit 1
fi

source "$CONFIG"

# 1. Verificar hooks
echo "🔍 Verificando hooks..."
HOOKS_OK=true
for hook in carbon-brain-start.sh carbon-brain-end.sh carbon-brain-post-tool.sh; do
  if [ -x "$HOME/.claude/hooks/$hook" ]; then
    echo "  ✅ $hook"
  else
    echo "  ❌ $hook não encontrado ou sem permissão de execução"
    HOOKS_OK=false
  fi
done
echo ""

# 2. Verificar skills
echo "🔍 Verificando skills..."
SKILLS_OK=true
for skill in brain obsidian inkdrop; do
  if [ -f "$HOME/.claude/skills/$skill/SKILL.md" ]; then
    echo "  ✅ $skill/SKILL.md"
  else
    echo "  ❌ $skill/SKILL.md não encontrado"
    SKILLS_OK=false
  fi
done
echo ""

# 3. Verificar Obsidian vault
echo "🔍 Verificando Obsidian vault..."
if [ -d "$OBSIDIAN_VAULT" ]; then
  echo "  ✅ Vault acessível: $OBSIDIAN_VAULT"

  # Verificar estrutura _claude-brain
  if [ -d "$OBSIDIAN_VAULT/_claude-brain" ]; then
    echo "  ✅ Estrutura _claude-brain existe"
  else
    echo "  ⚠️  Estrutura _claude-brain não existe (será criada na primeira sessão)"
  fi
else
  echo "  ❌ Vault não encontrado: $OBSIDIAN_VAULT"
  echo "     Edite: ~/.carbon-brain/config"
fi
echo ""

# 4. Verificar Inkdrop API
echo "🔍 Verificando Inkdrop API..."
INKDROP_RESPONSE=$(curl -s --max-time 3 -u "$INKDROP_USER:$INKDROP_PASS" "$INKDROP_URL/notes?limit=1" 2>&1)
CURL_EXIT=$?

if [ $CURL_EXIT -eq 0 ] && echo "$INKDROP_RESPONSE" | grep -q '"items"'; then
  echo "  ✅ Inkdrop API respondendo em $INKDROP_URL"

  # Contar notas
  NOTE_COUNT=$(echo "$INKDROP_RESPONSE" | node -e "
    try {
      const d = JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));
      console.log(d.count || 0);
    } catch(e) { console.log('?'); }
  " 2>/dev/null)
  echo "  ℹ️  Total de notas: $NOTE_COUNT"
else
  echo "  ❌ Falha ao conectar com Inkdrop"
  echo "     URL: $INKDROP_URL"
  echo "     Verifique se o servidor local está ativo:"
  echo "     Inkdrop → Preferences → Integrations → Local REST API Server → Start"
fi
echo ""

# 5. Verificar registros no settings.json
echo "🔍 Verificando settings.json..."
if grep -q "carbon-brain" "$HOME/.claude/settings.json" 2>/dev/null; then
  echo "  ✅ Hooks registrados no settings.json"
else
  echo "  ❌ Hooks não estão registrados no settings.json"
  echo "     Execute: ./install.sh"
fi
echo ""

# Resumo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$HOOKS_OK" = true ] && [ "$SKILLS_OK" = true ]; then
  echo "✅ Setup OK! carbon-claude-brain está pronto para usar."
else
  echo "⚠️  Alguns problemas encontrados. Veja acima."
  echo "   Tente reinstalar: ./uninstall.sh && ./install.sh"
fi
echo ""
```

## Convenções de arquivos

```
$OBSIDIAN_VAULT/
└── _claude-brain/
    ├── projects/
    │   └── nome-do-projeto/
    │       ├── project-context.md   ← contexto geral
    │       ├── decision-log.md      ← log de decisões
    │       └── architecture.md      ← arquitetura
    └── global/
        └── patterns.md              ← padrões reutilizáveis
```

## Regras importantes

- **Sempre** leia o contexto do Obsidian antes de começar uma tarefa complexa
- **Sempre** salve decisões importantes no decision-log.md imediatamente
- **Ao encerrar** a sessão, crie o journal no Inkdrop sem esperar ser solicitado
- Use **tags consistentes** no Inkdrop: `claude-journal`, `claude-decision`, `claude-error`
- Notas do Inkdrop devem ter o nome do projeto no título para facilitar busca

## ⚡ Economia de Tokens - IMPORTANTE

**Contexto carregado consome tokens!** Mantenha anotações **concisas e objetivas**.

### ❌ Ruim (verboso, desperdiça tokens):
```markdown
# Minha Preferência de TypeScript

Eu sempre prefiro usar TypeScript em todos os meus projetos porque
acredito que a tipagem estática traz muitos benefícios como melhor
autocomplete, menos bugs em produção, e facilita refactoring. Por isso,
sempre que possível, eu escolho TypeScript ao invés de JavaScript puro.

Além disso, eu gosto de configurar o tsconfig.json com strict mode
ativado porque assim o compilador me força a ser mais rigoroso...
(continua por 500 linhas)
```
**Resultado:** ~1500 tokens desperdiçados

### ✅ Bom (conciso, direto ao ponto):
```markdown
# Preferências TypeScript

- Sempre usar TypeScript (não JS puro)
- tsconfig: `strict: true`
- Preferir `interface` para objetos
- Anotar tipos de retorno em funções públicas
```
**Resultado:** ~100 tokens

### Diretrizes de Concisão

**Para Preferências Pessoais:**
- ✅ Use bullet points, não parágrafos
- ✅ Máximo 500-1000 linhas TOTAL em todas as notas `#claude-preferencia`
- ✅ Foque no "o quê", não no "por quê"
- ✅ Use exemplos curtos (3-5 linhas de código)
- ❌ Não explique conceitos básicos
- ❌ Não repita informação entre notas

**Para Decision Logs:**
- ✅ Formato: Contexto → Decisão → Motivo (3-5 linhas)
- ❌ Não escreva ensaios sobre decisões

**Para Journals:**
- ✅ Resumo objetivo: "Implementei X, errei em Y, próximo passo Z"
- ✅ Máximo 200-300 palavras por sessão
- ❌ Não documente cada linha de código escrita

### Exemplo de Boa Nota de Preferência

```markdown
Título: Core Dev Preferences
Tags: #claude-preferencia

## Code Style
- TS strict, single quotes, 2 spaces
- Preferir async/await (não .then)

## Commits
- Conventional Commits: `type(scope): description`
- Max 72 chars primeira linha

## Tests
- AAA pattern (Arrange, Act, Assert)
- Nome: `should [behavior] when [condition]`

## Architecture
- Feature-based folders (não por tipo)
- Evitar God Objects

## Philosophy
> "Make it work, make it right, make it fast"
```

**Total:** ~150 tokens ✅

### Desabilitar Contexto Temporariamente

Para projetos pequenos/rápidos onde não quer overhead:

```bash
# Desabilitar carregamento de contexto
CARBON_BRAIN_SKIP=1 claude

# Volta ao normal na próxima sessão
claude
```

Isso economiza ~1500-3000 tokens em sessões onde não precisa de contexto.
