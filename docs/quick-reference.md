# Referência Rápida — carbon-claude-brain

> Todos os comandos, atalhos e variáveis em um só lugar

---

## 🚀 Comandos Principais

### Instalação/Desinstalação

```bash
# Instalar
./install.sh

# Desinstalar
./uninstall.sh

# Testar se está funcionando
# (dentro do Claude Code, executar)
/carbon-brain-test
```

---

## 🎯 Skills Disponíveis

Execute **dentro do Claude Code** (não no terminal):

### `/carbon-brain-save`
Salva resumo da sessão atual no Obsidian + Inkdrop

**Uso:**
```
/carbon-brain-save
```

**Quando usar:** Ao final de uma sessão de trabalho

---

### `/carbon-brain-context`
Mostra o contexto carregado do Obsidian para o projeto atual

**Uso:**
```
/carbon-brain-context
```

**Quando usar:** Para verificar que contexto foi carregado

---

### `/carbon-brain-plan`
Cria ou atualiza o plano do projeto no Obsidian

**Uso:**
```
/carbon-brain-plan
```

**Quando usar:** No início do projeto ou ao planejar novas features

---

### `/carbon-brain-search`
Busca um termo em **todos os projetos** do Obsidian vault

**Uso:**
```bash
/carbon-brain-search "authentication"
/carbon-brain-search "docker compose"
/carbon-brain-search "rate limiting"
```

**Quando usar:** Encontrar como você resolveu algo em outro projeto

---

### `/carbon-brain-search-patterns`
Busca aprendizados gerais e padrões no **Inkdrop**

**Uso:**
```bash
/carbon-brain-search-patterns "error handling"
/carbon-brain-search-patterns "#react hooks"
/carbon-brain-search-patterns "typescript"
```

**Quando usar:** Buscar padrões/preferências pessoais que você documentou

---

### `/carbon-brain-test`
Diagnóstico completo do carbon-claude-brain

**Uso:**
```
/carbon-brain-test
```

**Quando usar:**
- Após instalação
- Quando algo não funciona
- Para verificar configuração

**Verifica:**
- ✅ Hooks instalados
- ✅ Skills instaladas
- ✅ Obsidian vault acessível
- ✅ Inkdrop API respondendo
- ✅ Hooks registrados no settings.json

---

## 🔧 Variáveis de Ambiente

### `CARBON_BRAIN_SKIP`

**Descrição:** Desabilita o carregamento de contexto temporariamente

**Uso:**
```bash
# Desabilitar contexto para esta sessão
CARBON_BRAIN_SKIP=1 claude

# Próxima sessão volta ao normal
cd /outro-projeto
claude
```

**Quando usar:**
- Scripts rápidos (1-3 perguntas)
- Projetos descartáveis
- Economizar tokens

**Economia:** ~1500-3000 tokens por sessão

---

## 📁 Estrutura de Arquivos

### Obsidian Vault

```
$OBSIDIAN_VAULT/
└── _claude-brain/
    ├── projects/
    │   └── nome-do-projeto/
    │       ├── project-context.md   ← Contexto geral do projeto
    │       ├── decision-log.md      ← Log de decisões técnicas
    │       └── architecture.md      ← Arquitetura do sistema
    └── global/
        └── patterns.md              ← Padrões reutilizáveis
```

### Inkdrop Tags

```
#claude-preferencia       → Preferências pessoais (carregadas automaticamente)
#claude-journal           → Journal de cada sessão
#claude-aprendizado       → Aprendizados gerais
#claude-pattern           → Padrões reutilizáveis
#claude-erro-resolvido    → Erros que você resolveu
```

### Arquivos de Configuração

```
~/.carbon-brain/
├── .env                        ← Credenciais (formato .env padrão, NUNCA commitar)
├── config                      ← [DEPRECATED] Mantido para compatibilidade
├── errors.log                  ← Log de erros dos hooks
└── activity.log                ← Log de atividades (rotacionado automaticamente)
```

---

## 🎨 Atalhos e Aliases (Opcional)

Adicione no `~/.bashrc` ou `~/.zshrc`:

```bash
# Alias para desabilitar contexto
alias claude-lite="CARBON_BRAIN_SKIP=1 claude"

# Alias para testar diagnóstico
alias brain-check="cd /Users/carbon/Projects/carbon-claude-brain && ./install.sh --verify"

# Alias para ver logs
alias brain-logs="tail -f ~/.carbon-brain/errors.log"
alias brain-activity="tail -20 ~/.carbon-brain/activity.log"

# Alias para editar preferências
alias brain-prefs="open inkdrop://note/[seu-note-id]"  # Substituir pelo ID da nota
```

**Usar:**
```bash
claude-lite              # Claude sem contexto
brain-logs               # Ver erros em tempo real
brain-activity           # Ver últimas atividades
```

---

## 🏷️ Tags Recomendadas no Inkdrop

### Estrutura de Tags

```
#claude-preferencia          → Carregado automaticamente em TODA sessão
#claude-journal              → Resumo de sessões
#claude-aprendizado          → Aprendizados gerais
#claude-pattern              → Padrões de código reutilizáveis
#claude-erro-resolvido       → Erros resolvidos (para não repetir)
#claude-decisao-rapida       → Decisões pequenas
```

### Tags de Tecnologia (Opcional)

```
#javascript
#typescript
#react
#nodejs
#python
#docker
#aws
```

**Uso combinado:**
```
Tags: #claude-pattern, #react, #hooks
Tags: #claude-aprendizado, #docker, #networking
```

---

## 📊 Consumo de Tokens

### Por Tipo de Sessão

| Sessão | Sem brain | Com brain | Economia |
|--------|-----------|-----------|----------|
| Rápida (1-3 msgs) | ~500 | ~2000 | ❌ Use `SKIP=1` |
| Média (5-10 msgs) | ~2000 | ~2500 | ⚖️ Neutro |
| Longa (15+ msgs) | ~5000 | ~4000 | ✅ +20% |

### Limites Recomendados

```
Preferências pessoais (Inkdrop):   500-1000 linhas TOTAL
Decision log (por decisão):         3-5 linhas
Journal (por sessão):               100-200 palavras
Exemplo de código:                  3-5 linhas
```

---

## 🔍 Comandos de Diagnóstico

### Verificar instalação

```bash
# Hooks instalados?
ls -la ~/.claude/hooks/carbon-brain-*.sh

# Skills instaladas?
ls -la ~/.claude/skills/{brain,obsidian,inkdrop}

# Config existe? (verifica .env e config antigo)
cat ~/.carbon-brain/.env
cat ~/.carbon-brain/config  # Compatibilidade com versão antiga

# Hooks registrados?
cat ~/.claude/settings.json | grep carbon-brain
```

### Testar Obsidian

```bash
# Vault acessível?
ls -la "$OBSIDIAN_VAULT/_claude-brain"

# Projeto tem contexto?
PROJECT="$(basename $(pwd))"
ls -la "$OBSIDIAN_VAULT/_claude-brain/projects/$PROJECT/"
```

### Testar Inkdrop

```bash
source ~/.carbon-brain/config

# API respondendo?
curl http://localhost:19840

# Buscar preferências
curl -s -u "$INKDROP_USER:$INKDROP_PASS" \
  "$INKDROP_URL/notes?keyword=claude-preferencia" | jq '.items[].title'

# Contar notas
curl -s -u "$INKDROP_USER:$INKDROP_PASS" \
  "$INKDROP_URL/notes" | jq '.count'
```

---

## 🐛 Troubleshooting Rápido

### Contexto não carrega

```bash
# 1. Verificar se hook está executando
bash ~/.claude/hooks/carbon-brain-start.sh

# 2. Ver erros
cat ~/.carbon-brain/errors.log

# 3. Testar Inkdrop API
source ~/.carbon-brain/config
curl -u "$INKDROP_USER:$INKDROP_PASS" "$INKDROP_URL/notes"
```

### Reinstalar do zero

```bash
cd /caminho/do/carbon-claude-brain
./uninstall.sh
./install.sh
```

### Ver o que foi carregado

```bash
# Dentro do Claude Code:
/carbon-brain-context
```

---

## 📚 Documentação Completa

| Documento | Conteúdo |
|-----------|----------|
| [README.md](../README.md) | Visão geral e instalação |
| [troubleshooting.md](troubleshooting.md) | Resolução de problemas |
| [setup-personal-preferences.md](setup-personal-preferences.md) | Como configurar preferências |
| [token-optimization.md](token-optimization.md) | Como economizar tokens |
| [setup-obsidian.md](setup-obsidian.md) | Configuração do Obsidian |
| [setup-inkdrop.md](setup-inkdrop.md) | Configuração do Inkdrop |

---

## 🎯 Fluxo de Trabalho Típico

### 1. Início de Projeto Novo

```bash
# Iniciar Claude Code
cd /novo-projeto
claude

# Criar plano do projeto
/carbon-brain-plan

# Trabalhar...
```

### 2. Continuando Projeto Existente

```bash
# Claude carrega contexto automaticamente
cd /projeto-existente
claude

# Ver contexto carregado (opcional)
/carbon-brain-context

# Trabalhar...
```

### 3. Fim de Sessão

```bash
# Salvar resumo
/carbon-brain-save

# Ou apenas sair (session-end.sh cria trigger)
exit
```

### 4. Script Rápido (sem contexto)

```bash
cd /script-temporario
CARBON_BRAIN_SKIP=1 claude

# Perguntar algo rápido
# Sair
```

### 5. Buscar Soluções Passadas

```bash
# Dentro do Claude Code:

# Buscar em projetos específicos
/carbon-brain-search "authentication jwt"

# Buscar padrões gerais
/carbon-brain-search-patterns "error handling"
```

---

## 🔑 Atalhos de Teclado (Inkdrop)

Dentro do Inkdrop app:

```
Cmd/Ctrl + N        → Nova nota
Cmd/Ctrl + Shift+T  → Adicionar tag
Cmd/Ctrl + K        → Buscar
```

**Workflow rápido:**
1. `Cmd+N` - Criar nota
2. Escrever conteúdo
3. `Cmd+Shift+T` - Adicionar `#claude-preferencia`
4. Salvar

---

## 💡 Dicas Rápidas

### ✅ Faça

- Use `CARBON_BRAIN_SKIP=1` para scripts rápidos
- Mantenha preferências < 1000 linhas total
- Use bullet points (não parágrafos)
- Rode `/carbon-brain-test` após instalação
- Salve decisões importantes imediatamente

### ❌ Evite

- Copiar templates inteiros para suas preferências
- Escrever journals muito longos (> 300 palavras)
- Criar 10+ notas de preferências
- Explicar conceitos básicos em preferências
- Deixar activity.log crescer indefinidamente (rotaciona automaticamente)

---

## 🆘 Ajuda Rápida

```bash
# Algo não funciona?
/carbon-brain-test

# Ver logs de erro
cat ~/.carbon-brain/errors.log

# Ver atividades recentes
tail -20 ~/.carbon-brain/activity.log

# Reinstalar
./uninstall.sh && ./install.sh

# Documentação completa
open docs/troubleshooting.md
```

---

**Versão:** 0.2.0
**Última atualização:** 2024-03-21
