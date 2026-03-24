# 🧠 carbon-claude-brain

> Memória persistente para o Claude Code usando Obsidian como segundo cérebro e Inkdrop como journal — sem banco de dados, sem serviços, sem complexidade.

[🇺🇸 English Version](README.md)

## Como funciona

### Ciclo de Vida de uma Sessão

```mermaid
flowchart TB
    Start([Iniciar Sessão]) --> Hook1[session-start.sh]
    Hook1 --> Obs1[📖 Carregar do Obsidian]
    Hook1 --> Ink1[📓 Carregar do Inkdrop]

    Obs1 --> |Contexto do Projeto|Load[Contexto Carregado]
    Obs1 --> |Conhecimento Global|Load
    Ink1 --> |Preferências Pessoais|Load
    Ink1 --> |Aprendizados Anteriores|Load

    Load --> Work[👨‍💻 Sessão de Código]

    Work --> Skills{Skills Disponíveis}
    Skills --> |/carbon-brain-plan|PlanSkill[Atualizar Plano]
    Skills --> |/carbon-brain-context|CtxSkill[Ver Contexto]
    Skills --> |/carbon-brain-search|SearchSkill[Buscar Projetos]
    Skills --> |/carbon-brain-search-patterns|PatternSkill[Buscar Padrões]

    PlanSkill --> SaveObs[💾 Salvar no Obsidian]

    Work --> Hook2[post-tool-use.sh]
    Hook2 --> |Decisões Importantes|Capture[Capturar Notas]

    Work --> End([Encerrar Sessão])
    End --> Hook3[session-end.sh]
    Hook3 --> SaveObs2[💾 Atualizar Status no Obsidian]
    Hook3 --> SaveInk[📓 Salvar Journal no Inkdrop]

    style Start fill:#fff,stroke:#000,stroke-width:3px
    style End fill:#fff,stroke:#000,stroke-width:3px
    style Work fill:#fff,stroke:#000,stroke-width:2px
    style Load fill:#fff,stroke:#000,stroke-width:2px
    style Skills fill:#fff,stroke:#000,stroke-width:2px
```

### Visão Geral da Arquitetura

```mermaid
graph LR
    Claude[🤖 Claude Code]
    Projeto[📁 Seu Projeto]

    Obsidian[📖 Obsidian<br/>Conhecimento do Projeto<br/><small>planos, decisões, arquitetura</small>]
    Inkdrop[📓 Inkdrop<br/>Memória Pessoal<br/><small>preferências, aprendizados, padrões</small>]

    Claude -->|trabalha em| Projeto

    Claude -->|lê ao iniciar| Obsidian
    Claude -->|lê ao iniciar| Inkdrop

    Claude -->|salva ao encerrar| Obsidian
    Claude -->|salva ao encerrar| Inkdrop

    style Claude fill:#fff,stroke:#000,stroke-width:3px
    style Projeto fill:#fff,stroke:#000,stroke-width:2px
    style Obsidian fill:#fff,stroke:#000,stroke-width:2px
    style Inkdrop fill:#fff,stroke:#000,stroke-width:2px
```

**Regra de Negócio:**
1. **Início da Sessão** — Claude carrega automaticamente:
   - Conhecimento global (aprendizados, erros resolvidos, padrões)
   - Contexto do projeto e decisões recentes
   - Preferências pessoais do Inkdrop
2. **Trabalho** — Claude programa no seu projeto com contexto completo
3. **Fim da Sessão** — Claude salva automaticamente decisões no Obsidian e aprendizados no Inkdrop

**O que é carregado em cada sessão:**
- ⚙️ Preferências pessoais (Inkdrop)
- 📚 Aprendizados globais (conhecimento cross-project)
- 🐛 Erros previamente resolvidos
- 🎯 Padrões de código reutilizáveis
- 📁 Contexto do projeto atual
- 🏛️ Decisões técnicas recentes
- 📔 Journal da última sessão

## Pré-requisitos

- [Claude Code](https://claude.ai/claude-code) instalado
- [Obsidian](https://obsidian.md) com vault local configurado
- [Inkdrop](https://www.inkdrop.app) com servidor local ativo (`localhost:19840`) — **opcional**
- `bash` ≥4.0, `curl`, `node` (geralmente já vêm instalados)

## Instalação

### Opção 1: Marketplace (Recomendado)

Instale diretamente do marketplace de plugins:

```bash
# Adicionar o marketplace
/plugin marketplace add marcoscarvalhodearaujo/carbon-claude-brain

# Instalar o plugin
/plugin install carbon-claude-brain@carbon-claude-brain

# Executar o wizard de configuração
/carbon-brain-setup
```

#### Modos de Configuração

**Modo Interativo (Padrão):**
O wizard fará perguntas passo a passo:
- ✅ Configuração do caminho do vault do Obsidian
- ✅ Setup do Inkdrop (opcional)
- ✅ Criação da estrutura de diretórios
- ✅ Validação da configuração inicial

**Modo Não-Interativo (Avançado):**
Para setup automatizado ou configuração reproduzível:

1. Copie o exemplo de configuração:
   ```bash
   cp ${CLAUDE_PLUGIN_ROOT}/.env.example ${CLAUDE_PLUGIN_ROOT}/.env
   ```

2. Edite o `.env` com suas configurações:
   ```bash
   # Obrigatório
   OBSIDIAN_VAULT="/Users/seu-usuario/Documents/MeuVault"

   # Opcional - deixe vazio para desabilitar Inkdrop
   INKDROP_URL=""
   INKDROP_USER=""
   INKDROP_PASS=""
   ```

3. Execute o setup:
   ```bash
   /carbon-brain-setup
   ```

O script detectará o arquivo `.env` e executará sem prompts.

**Vantagens:**
- 🚀 Atualizações automáticas
- 🔧 Instalação com um comando
- 📦 Sem cópia manual de arquivos
- ✅ Releases validados

### Opção 2: Instalação Manual

Clone e instale manualmente:

```bash
git clone https://github.com/marcoscarvalhodearaujo/carbon-claude-brain
cd carbon-claude-brain
./install.sh
```

O script vai perguntar:
- Caminho do vault do Obsidian
- Credenciais do servidor local do Inkdrop
- (Opcional) ID do Notebook do Inkdrop onde as notas devem ser criadas

**Quando usar:**
- 🔬 Testar versões de desenvolvimento
- 🛠️ Modificações customizadas
- 📝 Contribuir para o projeto

### ⚠️ Nota sobre Segurança

As credenciais do Inkdrop são armazenadas em `~/.carbon-brain/.env` (formato padrão `.env` com permissões `600`). Isso é aceitável porque:
- O servidor do Inkdrop é **local** (`localhost:19840`)
- Não é exposto à internet
- Apenas você tem acesso à sua máquina
- Formato `.env` padrão universal (compatível com Docker, etc.)

**Recomendações:**
- ✅ Use senha diferente do seu Inkdrop Cloud
- ✅ Mantenha o servidor local desabilitado quando não usar
- ❌ **NUNCA** versione ou compartilhe `~/.carbon-brain/.env`
- 🔒 `.env` já está no `.gitignore` por padrão

**Para desinstalar completamente:**
```bash
./uninstall.sh
```

## O Que Faz

### Obsidian — Conhecimento do Projeto (Local)
- Planos e arquitetura de implementação
- Log de decisões técnicas
- Documentação viva do projeto

### Inkdrop — Conhecimento Pessoal (Sincroniza)
- Preferências pessoais (aplicam a todos os projetos)
- Journals de sessões
- Aprendizados gerais e padrões
- Erros resolvidos

## 🤖 Auto-Save (NOVO!)

Resumos de sessão agora são **salvos automaticamente** quando você fecha o Claude Code.

- **O que:** Resumo inteligente gerado analisando o transcript da sessão
- **Quando:** Automaticamente ao encerrar sessão (Ctrl+C, exit)
- **Onde:** Journals do Obsidian + Inkdrop (se habilitado)
- **Modelo:** Usa Claude Haiku (rápido, leve)
- **Tempo:** Adiciona ~5-10s ao fechamento da sessão

**Formato salvo:**
```markdown
### O que foi feito
- Feature X implementada
- Bug Y corrigido

### Erros e aprendizados
- Problema: timeout na API → Solução: aumentei para 5s

### Próximos passos
- [ ] Adicionar testes
- [ ] Deploy em staging
```

**[→ Documentação do Auto-Save](docs/auto-save.md)**

Você ainda pode usar `/carbon-brain-save` manualmente para ter mais controle.

## Skills Disponíveis

| Skill | Propósito |
|-------|-----------|
| `/carbon-brain-setup` | Executar wizard de configuração (setup inicial) |
| `/carbon-brain-test` | Verificar instalação e diagnósticos |
| `/carbon-brain-context` | Ver contexto carregado |
| `/carbon-brain-plan` | Criar/atualizar plano do projeto |
| `/carbon-brain-save` | Salvar resumo da sessão (opcional - agora auto-salva) |
| `/carbon-brain-search` | Buscar em todos os projetos |
| `/carbon-brain-search-patterns` | Buscar conhecimento pessoal |
| `/carbon-brain-learn` | Salvar aprendizado reutilizável |
| `/carbon-brain-error` | Documentar erro resolvido |
| `/carbon-brain-setup` | Listar notebooks do Inkdrop e configurar destino |

**[→ Documentação Completa dos Skills](docs/skills-guide.md)**

---

## Uso de Tokens

**Injeção de contexto:** ~1500-3000 tokens por sessão
**Auto-save:** ~2000-10000 tokens por sessão (usa agent interno do Claude Code)

| Tipo de Sessão | Tokens Contexto | Tokens Auto-Save | Total | Vale a Pena? |
|----------------|-----------------|------------------|-------|--------------|
| Rápida (1-3 msgs) | 1500 tokens | ~2000 tokens | ~3500 | ⚖️ Marginal |
| Média (5-10 msgs) | 2000 tokens | ~5000 tokens | ~7000 | ✅ Sim |
| Longa (15+ msgs) | 3000 tokens | ~8000 tokens | ~11000 | ✅ Definitivamente |

**Nota:** Auto-save usa sua cota/sessão do Claude Code - sem custos adicionais de API.

**Desabilitar temporariamente:**
```bash
CARBON_BRAIN_SKIP=1 claude
```

**[→ Guia de Otimização de Tokens](docs/token-optimization.md)**

---

## Documentação

### 📚 Setup & Configuração
- [Setup do Obsidian](docs/setup-obsidian.md)
- [Setup do Inkdrop](docs/setup-inkdrop.md)
- [Preferências Pessoais](docs/setup-personal-preferences.md)
- [Melhores Práticas de Segurança](docs/security-best-practices.md)

### 🎯 Guias de Uso
- [Auto-Save Feature](docs/auto-save.md) - Resumos automáticos de sessão
- [Referência de Skills](docs/skills-guide.md)
- [Cartão de Referência Rápida](docs/quick-reference.md)
- [Otimização de Tokens](docs/token-optimization.md)
- [Troubleshooting](docs/troubleshooting.md)

### 🔍 Comparações & Decisões
- [vs claude-mem](docs/comparison.md) - Qual usar?

---

## Contribuindo

Contribuições são bem-vindas! Veja [CONTRIBUTING.md](CONTRIBUTING.md).

**Segurança:** [SECURITY.md](SECURITY.md) | **Branch Protection:** [docs/branch-protection.md](docs/branch-protection.md)

---

## Desinstalar

```bash
./uninstall.sh
```

## Licença

MIT
