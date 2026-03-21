---
name: obsidian
description: >
  Skill para interagir com o vault local do Obsidian via filesystem.
  Use para ler e escrever notas de projeto, decisões e arquitetura.
  Trigger: quando o usuário mencionar "obsidian", "vault", "plano do projeto",
  "arquitetura" ou "decisão técnica".
---

# Obsidian — Segundo Cérebro

O Obsidian é usado como repositório de conhecimento **persistente e estruturado** do projeto.
O vault está no filesystem local — acesso direto via bash, sem API.

## Estrutura do vault

```
$OBSIDIAN_VAULT/
└── _claude-brain/
    ├── projects/
    │   └── {nome-do-projeto}/
    │       ├── project-context.md    ← O que é o projeto, stack, convenções
    │       ├── decision-log.md       ← Decisões técnicas com data e motivo
    │       └── architecture.md      ← Diagrama/descrição da arquitetura
    └── global/
        └── patterns.md              ← Padrões reutilizáveis entre projetos
```

## Como ler notas

```bash
# Ler contexto do projeto atual
PROJECT="$(basename $(pwd))"
cat "$OBSIDIAN_VAULT/_claude-brain/projects/$PROJECT/project-context.md"

# Listar todos os projetos com contexto
ls "$OBSIDIAN_VAULT/_claude-brain/projects/"
```

## Como escrever notas

```bash
# Criar pasta do projeto se não existir
mkdir -p "$OBSIDIAN_VAULT/_claude-brain/projects/$PROJECT"

# Adicionar decisão ao log
cat >> "$OBSIDIAN_VAULT/_claude-brain/projects/$PROJECT/decision-log.md" <<EOF

## $(date '+%Y-%m-%d %H:%M') — Título da Decisão
**Contexto:** Por que surgiu essa decisão
**Decisão:** O que foi decidido
**Motivo:** Por que essa opção foi escolhida
**Alternativas:** O que foi descartado e por quê
EOF
```

## Quando usar

| Situação | Ação |
|---|---|
| Início da sessão | Ler `project-context.md` |
| Decisão técnica tomada | Append em `decision-log.md` |
| Mudança de arquitetura | Atualizar `architecture.md` |
| Padrão reutilizável descoberto | Append em `global/patterns.md` |
| Plano de implementação | Criar/atualizar `project-context.md` |

## Formato do project-context.md

```markdown
# {Nome do Projeto}

## Stack
- Runtime: Node.js 20
- ORM: Sequelize
- Framework: Express

## Convenções
- ...

## Estado atual
- Última atualização: YYYY-MM-DD
- Em andamento: ...
- Próximos passos: ...
```
