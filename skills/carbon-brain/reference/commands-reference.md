# Commands Reference

Referência completa de todos os comandos do carbon-claude-brain.

## /brain-save

**Propósito:** Salva resumo da sessão em Obsidian + Inkdrop

**Quando usar:**
- Ao final de cada sessão de trabalho
- Quando completar uma tarefa importante
- Antes de mudar de contexto/projeto

**Comportamento:**
- **Obsidian:** SEMPRE salva em `_claude-brain/global/journals/YYYY-MM-DD.md`
- **Inkdrop:** Se configurado, salva com tag `#claude-journal`
- Múltiplas sessões no mesmo dia = append com separador
- Se Inkdrop offline → warning, continua apenas com Obsidian

**Implementação:** Ver [brain-save-example.sh](../examples/brain-save-example.sh)

**Funções lib-carbon-brain.sh:**
- `save_to_obsidian_journal()` - salva no Obsidian
- `save_to_inkdrop_journal()` - salva no Inkdrop (opcional)
- `is_inkdrop_enabled()` - verifica se Inkdrop está configurado

---

## /brain-learn

**Propósito:** Salva aprendizado reutilizável em `global/learnings.md`

**Quando usar:**
- Descobrir regra geral que vale para qualquer projeto
- Aprender algo que quer lembrar no futuro
- Identificar melhor prática

**Categorias disponíveis:**
- Desenvolvimento
- Arquitetura
- Performance
- Segurança
- Testing
- DevOps

**Exemplo de uso:**
```bash
save_learning "Performance" "Sempre adicionar índice em colunas usadas em WHERE/JOIN"
```

**Implementação:** Ver [brain-learn-example.sh](../examples/brain-learn-example.sh)

**Função lib-carbon-brain.sh:**
- `save_learning(categoria, texto)` - adiciona em learnings.md

---

## /brain-error

**Propósito:** Documenta erro resolvido em `global/errors-solved.md`

**Quando usar:**
- Resolver erro que demorou para descobrir
- Encontrar solução não óbvia
- Querer evitar repetir o mesmo erro

**Parâmetros:**
1. Data (YYYY-MM-DD)
2. Título do erro
3. Contexto (o que estava fazendo)
4. Mensagem de erro
5. Solução aplicada
6. Como prevenir no futuro

**Implementação:** Ver [brain-error-example.sh](../examples/brain-error-example.sh)

**Função lib-carbon-brain.sh:**
- `save_error_solved(data, titulo, contexto, erro, solucao, prevencao)`

---

## /brain-context

**Propósito:** Mostra contexto atual carregado do Obsidian

**Quando usar:**
- Verificar que informações estão disponíveis
- Debug de carregamento de contexto
- Ver estrutura de arquivos do projeto

**Implementação:** Skill separada em `carbon-brain-context/SKILL.md`

---

## /brain-plan

**Propósito:** Cria/atualiza plano do projeto em Obsidian

**Quando usar:**
- Início de novo projeto
- Mudança de arquitetura
- Documentar decisões importantes

**Arquivo criado:** `_claude-brain/projects/$PROJECT/project-context.md`

**Implementação:** Skill separada em `carbon-brain-plan/SKILL.md`

---

## /brain-search

**Propósito:** Busca cross-project no Obsidian vault

**Quando usar:**
- Lembrar como resolveu problema similar
- Encontrar decisões técnicas relacionadas
- Ver padrões em múltiplos projetos
- Descobrir aprendizados passados

**Uso:**
```bash
/brain-search "authentication"
/brain-search "rate limiting redis"
/brain-search "docker compose"
```

**Escopo:** Busca em **todos os projetos** do vault

**Implementação:** Ver [brain-search-example.sh](../examples/brain-search-example.sh)

---

## /brain-search-patterns

**Propósito:** Busca aprendizados gerais no Inkdrop

**Quando usar:**
- Procurar patterns reutilizáveis
- Buscar aprendizados não específicos de projeto
- Encontrar preferências documentadas

**Uso:**
```bash
/brain-search-patterns "error handling"
/brain-search-patterns "docker compose"
/brain-search-patterns "#react hooks"
```

**Escopo:** Busca no **Inkdrop** (conhecimento global)

**Tags filtradas:**
- `#claude-pattern` - Padrões de código
- `#claude-aprendizado` - Aprendizados gerais
- `#claude-erro-resolvido` - Erros documentados
- `#claude-preferencia` - Preferências pessoais

**Diferença de /brain-search:**
- `/brain-search` → Obsidian (projetos específicos)
- `/brain-search-patterns` → Inkdrop (conhecimento global)

**Implementação:** Ver [brain-search-patterns-example.sh](../examples/brain-search-patterns-example.sh)

---

## /brain-test

**Propósito:** Diagnóstico completo do sistema

**Quando usar:**
- Após instalação
- Debug de problemas
- Verificar configuração

**Verifica:**
1. Hooks instalados e executáveis
2. Skills disponíveis
3. Obsidian vault acessível
4. Inkdrop API respondendo
5. Registro no settings.json

**Implementação:** Ver [brain-test-example.sh](../examples/brain-test-example.sh)

---

## /brain-setup

**Propósito:** Configurar notebook do Inkdrop

**Quando usar:**
- Organizar notas em notebooks específicos
- Listar notebooks disponíveis

**Implementação:** Skill separada em `carbon-brain-setup/SKILL.md`

---

## Arquivos de Conhecimento Global

### Estrutura
```
_claude-brain/global/
├── journals/           # Sessões diárias (automático via /brain-save)
├── learnings.md        # Aprendizados reutilizáveis
├── errors-solved.md    # Erros resolvidos (lições aprendidas)
└── patterns.md         # Padrões de código/arquitetura
```

### Quando usar cada arquivo

**journals/** - Use automaticamente via `/brain-save`
- O que foi feito na sessão
- Contexto temporal (hoje, essa semana)

**learnings.md** - Use quando descobrir **conhecimento reutilizável**
- Regras gerais que valem para qualquer projeto
- "Sempre validar inputs antes de processar"
- "Usar timeout de 5s em requests externos"

**errors-solved.md** - Use quando **resolver erro não óbvio**
- Erro que demorou para resolver
- Erro que pode acontecer de novo
- Lição importante para não repetir

**patterns.md** - Use para **padrões de código**
- Snippets reutilizáveis
- Estruturas que funcionam bem
- Arquiteturas comprovadas

---

## Convenções de Arquivos

```
$OBSIDIAN_VAULT/
└── _claude-brain/
    ├── projects/
    │   └── nome-do-projeto/
    │       ├── project-context.md   ← contexto geral
    │       ├── decision-log.md      ← log de decisões
    │       └── architecture.md      ← arquitetura
    └── global/
        ├── journals/                ← sessões diárias
        ├── learnings.md             ← aprendizados globais
        ├── errors-solved.md         ← erros resolvidos
        └── patterns.md              ← padrões reutilizáveis
```

---

## Economia de Tokens

Mantenha notas **concisas e objetivas** - contexto carregado consome tokens!

### ❌ Ruim (verboso):
```markdown
# Minha Preferência de TypeScript

Eu sempre prefiro usar TypeScript em todos os meus projetos porque
acredito que a tipagem estática traz muitos benefícios...
(continua por 500 linhas)
```

### ✅ Bom (conciso):
```markdown
# Preferências TypeScript

- Sempre usar TypeScript (não JS puro)
- tsconfig: `strict: true`
- Preferir `interface` para objetos
- Anotar tipos de retorno em funções públicas
```

### Diretrizes:
- Use bullet points, não parágrafos
- Máximo 500-1000 linhas TOTAL em preferências
- Foque no "o quê", não no "por quê"
- Exemplos curtos (3-5 linhas)
- Não repita informação entre notas

### Desabilitar contexto temporariamente:
```bash
# Para sessões rápidas sem overhead
CARBON_BRAIN_SKIP=1 claude
```

Economiza ~1500-3000 tokens por sessão.
