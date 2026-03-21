# Setup — Preferências Pessoais

> Como configurar suas preferências pessoais que serão carregadas em TODA sessão do Claude Code, independente do projeto ou máquina.

---

## Por que usar Inkdrop para preferências?

Suas preferências pessoais ficam no **Inkdrop** (não no Obsidian) porque:

✅ **Sincronizam entre máquinas** - Trabalho ↔ Casa via Inkdrop Cloud
✅ **São universais** - Aplicam-se a todos os projetos
✅ **São pessoais** - Não dependem do vault da empresa
✅ **Sempre disponíveis** - Mesmo em novos projetos sem contexto

---

## Como funciona?

1. Você cria notas no Inkdrop com tag `#claude-preferencia`
2. O `session-start.sh` carrega automaticamente essas notas
3. Claude vê suas preferências em **toda sessão**, em qualquer projeto

---

## Passo 1: Criar suas preferências no Inkdrop

### Exemplo 1: Preferências Gerais

**Criar nota no Inkdrop:**
```
Título: Minhas Preferências de Desenvolvimento
Tags: #claude-preferencia

Corpo:
# Preferências Gerais

## Estilo de Código
- Sempre usar **TypeScript** quando possível
- Preferir **single quotes** (`'`) em JavaScript/TypeScript
- Indentação: **2 espaços** (não tabs)
- Sempre incluir ponto e vírgula (`;`)

## Commits
- **Sempre** usar Conventional Commits
- Formato: `type(scope): description`
- Exemplos: `feat(auth): add login`, `fix(api): prevent crash`

## Testes
- Sempre escrever testes para features novas
- Usar padrão AAA (Arrange, Act, Assert)
- Nome descritivo: `should [behavior] when [condition]`

## Arquitetura
- Preferir organização por **feature** em vez de tipo
- Evitar God Objects / God Classes
- Simplicidade > Inteligência

## Filosofia
> "Make it work, make it right, make it fast — nessa ordem"
```

### Exemplo 2: Code Style Específico

**Criar outra nota no Inkdrop:**
```
Título: Meu Guia de Estilo - JavaScript/TypeScript
Tags: #claude-preferencia, #javascript, #typescript

Corpo:
# JavaScript / TypeScript Style

## Naming
- Classes: `PascalCase`
- Functions/Variables: `camelCase`
- Constants: `UPPER_SNAKE_CASE`
- Private members: `_underscore` prefix

## Functions
- ✅ Preferir arrow functions para callbacks
- ✅ Async/await sempre (não .then())
- ✅ Destructuring em parâmetros

## Types
- Sempre anotar tipos de retorno de funções públicas
- Preferir `interface` para objetos extensíveis
- Preferir `type` para unions e helpers

## Error Handling
- Custom error classes sempre
- Try/catch em todas as async functions
- Re-throw errors desconhecidos
```

### Exemplo 3: React Preferences

**Criar terceira nota:**
```
Título: Minhas Convenções de React
Tags: #claude-preferencia, #react

Corpo:
# React Conventions

## Component Structure
1. Imports
2. Types/Interfaces
3. Component function
4. Hooks
5. Event handlers
6. Render logic
7. Return JSX

## Hooks
- Custom hooks sempre com prefix "use"
- useMemo apenas quando necessário (measure first)
- useCallback para event handlers passados como props

## JSX
- Preferir ternário em vez de && para condicional
- Sempre usar key em listas
- Fragments sem key: `<>` em vez de `<Fragment>`
```

---

## Passo 2: Testar se está funcionando

### Verificar se notas foram criadas

```bash
# Testar API do Inkdrop
source ~/.carbon-brain/config

curl -u "$INKDROP_USER:$INKDROP_PASS" \
  "$INKDROP_URL/notes?keyword=claude-preferencia" | jq '.items[].title'
```

Deve listar suas notas com tag `#claude-preferencia`.

### Iniciar sessão do Claude Code

```bash
cd /qualquer/projeto
claude
```

Você deve ver no início:

```
---
🧠 carbon-claude-brain — contexto carregado para `projeto`

## ⚙️ Minhas Preferências Pessoais (Inkdrop)

### Minhas Preferências de Desenvolvimento

# Preferências Gerais
...

---

### Meu Guia de Estilo - JavaScript/TypeScript
...

---
```

---

## Passo 3: Manter atualizado

### Adicionar novas preferências

Basta criar nova nota no Inkdrop com tag `#claude-preferencia`. Será carregada na próxima sessão.

### Editar preferências existentes

Edite a nota no Inkdrop. Mudanças são visíveis na próxima sessão do Claude Code.

### Remover preferências

Remova a tag `#claude-preferencia` da nota ou delete a nota.

---

## Organização Recomendada

### Tags Combinadas

Use tags adicionais para categorizar:

```
Tags: #claude-preferencia, #javascript
Tags: #claude-preferencia, #python
Tags: #claude-preferencia, #react
Tags: #claude-preferencia, #commits
```

Isso permite buscar depois:
```bash
/brain-search-patterns "#javascript"
/brain-search-patterns "#react"
```

### Múltiplas Notas vs Nota Única

**Opção 1: Nota única grande**
- ✅ Tudo em um lugar
- ❌ Pode ficar muito grande e poluir o contexto

**Opção 2: Múltiplas notas por tema**
- ✅ Mais organizado
- ✅ Pode ativar/desativar removendo tag
- ✅ Mais fácil de editar temas específicos
- ⚠️ Limite de ~5 notas (evitar poluir contexto)

**Recomendação:**
- 1 nota de "Preferências Gerais" (filosofia, commits, etc)
- 1 nota por linguagem/framework principal que você usa
- Total: ~3-5 notas máximo

---

## Templates Disponíveis

Use os guias em `templates/inkdrop/` como base:

1. **`my-preferences-guide.md`** - Template completo de preferências gerais
2. **`code-style-guide.md`** - Guia detalhado de estilo de código

**Como usar:**
1. Abrir o template no editor
2. Copiar seções relevantes para você
3. Criar nota no Inkdrop com o conteúdo
4. Adicionar tag `#claude-preferencia`

---

## Boas Práticas

### ✅ Faça

- Seja específico e conciso
- Inclua exemplos quando possível
- Mantenha atualizado com sua evolução
- Use seções claras (##, ###)
- Explique o "por quê" das preferências

### ❌ Evite

- Notas muito longas (limite ~1000 linhas total)
- Informações óbvias ou redundantes
- Duplicação entre notas
- Muito genérico ("escreva código limpo")
- Preferências contraditórias em notas diferentes

---

## Diferença: Obsidian vs Inkdrop

| O que? | Onde? | Por quê? |
|--------|-------|----------|
| **Preferências pessoais** | Inkdrop | Sincroniza entre máquinas |
| **Padrões universais seus** | Inkdrop | Aplicam-se a todos os projetos |
| **Aprendizados gerais** | Inkdrop | Não são específicos de projeto |
| **Contexto do projeto X** | Obsidian | Específico deste projeto/empresa |
| **Arquitetura do sistema Y** | Obsidian | Documentação do projeto |
| **Decisões técnicas do projeto Z** | Obsidian | Histórico local do projeto |

---

## Exemplo Completo: Setup do Zero

```bash
# 1. Abrir Inkdrop e criar nota:

Título: Minhas Preferências Core
Tags: #claude-preferencia

Corpo:
# Preferências Pessoais

## Estilo de Código
- TypeScript strict mode sempre
- Single quotes em JS/TS
- 2 espaços de indentação
- Sempre ponto e vírgula

## Commits
- Conventional Commits obrigatório
- Primeira linha: máx 72 chars

## Arquitetura
- Feature-based organization
- Simplicidade > Clever code

## Testes
- Sempre testar features novas
- Padrão AAA (Arrange, Act, Assert)

---

# 2. Salvar no Inkdrop

# 3. Iniciar Claude Code em qualquer projeto

$ cd ~/projeto-qualquer
$ claude

# 4. Verificar que preferências foram carregadas

Deve aparecer:
"## ⚙️ Minhas Preferências Pessoais (Inkdrop)"
```

---

## Troubleshooting

### Preferências não aparecem

**Verificar:**
```bash
# 1. Inkdrop está rodando?
curl http://localhost:19840

# 2. Nota tem a tag correta?
# Deve ter exatamente: #claude-preferencia (sem maiúsculas)

# 3. Buscar manualmente
curl -u "$INKDROP_USER:$INKDROP_PASS" \
  "$INKDROP_URL/notes?keyword=claude-preferencia"
```

### Contexto muito poluído

- Reduza o tamanho das notas (máx 500-1000 linhas cada)
- Mantenha apenas 3-5 notas de preferências
- Remova informações redundantes

### Preferências diferentes entre projetos

Se você quer preferências diferentes para projetos pessoais vs trabalho:

**Opção 1:** Tags adicionais
```
Tags: #claude-preferencia, #trabalho
Tags: #claude-preferencia, #pessoal
```

Depois filtre no session-start.sh (customização avançada)

**Opção 2:** Vaults separados no Obsidian + mesmas preferências do Inkdrop
- Vault trabalho: projetos da empresa
- Vault pessoal: projetos pessoais
- Inkdrop: preferências universais (sincronizam em ambos)

---

## Próximos Passos

1. ✅ Criar 1-3 notas de preferências no Inkdrop
2. ✅ Adicionar tag `#claude-preferencia`
3. ✅ Testar iniciando Claude Code
4. ✅ Iterar e refinar suas preferências ao longo do tempo

**Dica:** Comece simples (1 nota pequena) e expanda conforme necessário. É melhor ter preferências concisas e úteis do que um documento enorme que ninguém lê.
