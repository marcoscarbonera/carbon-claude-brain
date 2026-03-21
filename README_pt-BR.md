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
    Ink1 --> |Preferências Pessoais|Load
    Ink1 --> |Aprendizados Anteriores|Load

    Load --> Work[👨‍💻 Sessão de Código]

    Work --> Skills{Skills Disponíveis}
    Skills --> |/brain-plan|PlanSkill[Atualizar Plano]
    Skills --> |/brain-context|CtxSkill[Ver Contexto]
    Skills --> |/brain-search|SearchSkill[Buscar Projetos]
    Skills --> |/brain-search-patterns|PatternSkill[Buscar Padrões]

    PlanSkill --> SaveObs[💾 Salvar no Obsidian]

    Work --> Hook2[post-tool-use.sh]
    Hook2 --> |Decisões Importantes|Capture[Capturar Notas]

    Work --> End([Encerrar Sessão])
    End --> Hook3[session-end.sh]
    Hook3 --> SaveObs2[💾 Atualizar Status no Obsidian]
    Hook3 --> SaveInk[📓 Salvar Journal no Inkdrop]

    style Start fill:#a8e6cf
    style End fill:#ff8b94
    style Work fill:#ffd3b6
    style Load fill:#dcedc1
    style Skills fill:#ffaaa5
```

### Visão Geral da Arquitetura

```mermaid
graph TB
    subgraph "Claude Code"
        CC[Sessão Claude]
        Hooks[Sistema de Hooks]
        Skills[Sistema de Skills]
    end

    subgraph "Armazenamento Local - Obsidian"
        OVault[📂 Vault Obsidian]
        OBrain[_claude-brain/]
        OProject[nome-projeto.md]
        OPlan[plano.md]
        ODocs[docs/]

        OVault --> OBrain
        OBrain --> OProject
        OBrain --> OPlan
        OBrain --> ODocs
    end

    subgraph "Armazenamento Sincronizado - Inkdrop"
        IServer[🌐 Servidor Local :19840]
        IPrefs[#claude-preferencia]
        IJournal[#claude-journal]
        ILearnings[#claude-aprendizado]
        IPatterns[#claude-pattern]
        IErrors[#claude-erro-resolvido]

        IServer --> IPrefs
        IServer --> IJournal
        IServer --> ILearnings
        IServer --> IPatterns
        IServer --> IErrors
    end

    subgraph "Arquivos do Projeto"
        Proj[📁 Seu Projeto]
        Code[Código Fonte]

        Proj --> Code
    end

    CC -->|Lê Contexto| Hooks
    Hooks -->|session-start| OBrain
    Hooks -->|session-start| IServer
    Hooks -->|post-tool-use| OBrain
    Hooks -->|session-end| OBrain
    Hooks -->|session-end| IServer

    CC -->|Comandos| Skills
    Skills -->|/brain-plan| OBrain
    Skills -->|/brain-search| OBrain
    Skills -->|/brain-search-patterns| IServer
    Skills -->|/brain-context| OBrain

    CC -->|Trabalha em| Proj

    style CC fill:#a8e6cf
    style OVault fill:#ffd3b6
    style IServer fill:#dcedc1
    style Proj fill:#ffaaa5
    style Hooks fill:#98d8c8
    style Skills fill:#f7dc6f
```

## Pré-requisitos

- [Claude Code](https://claude.ai/claude-code) instalado
- [Obsidian](https://obsidian.md) com vault local configurado
- [Inkdrop](https://www.inkdrop.app) com servidor local ativo (`localhost:19840`)

## Instalação

```bash
git clone https://github.com/marcoscarbonera/carbon-claude-brain
cd carbon-claude-brain
./install.sh
```

O script vai perguntar:
- Caminho do vault do Obsidian
- Credenciais do servidor local do Inkdrop

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

## Skills Disponíveis

| Skill | Propósito |
|-------|-----------|
| `/brain-test` | Verificar instalação |
| `/brain-context` | Ver contexto carregado |
| `/brain-plan` | Criar/atualizar plano do projeto |
| `/brain-save` | Salvar resumo da sessão |
| `/brain-search` | Buscar em todos os projetos |
| `/brain-search-patterns` | Buscar conhecimento pessoal |

**[→ Documentação Completa dos Skills](docs/skills-guide.md)**

---

## Uso de Tokens

Injeção de contexto custa ~1500-3000 tokens por sessão.

| Tipo de Sessão | Vale a Pena? |
|----------------|--------------|
| Rápida (1-3 msgs) | ❌ Não recomendado |
| Média (5-10 msgs) | ⚖️ Empate |
| Longa (15+ msgs) | ✅ Economiza tokens no geral |

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
