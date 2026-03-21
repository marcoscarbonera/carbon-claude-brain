# Setup — Obsidian

## Pré-requisitos

- Obsidian instalado com um vault criado
- Saber o caminho do vault (ex: `~/Documents/MeuVault`)

## Configuração automática

O `install.sh` cria automaticamente a pasta `_claude-brain` dentro do vault com os templates.

## Estrutura criada

```
SEU_VAULT/
└── _claude-brain/
    ├── projects/       ← um subdir por projeto
    └── global/
        └── patterns.md
```

## Uso manual

Para criar o contexto de um projeto antes da primeira sessão:

```bash
PROJECT="nome-do-projeto"
VAULT="~/Documents/MeuVault"

mkdir -p "$VAULT/_claude-brain/projects/$PROJECT"
cp templates/obsidian/project-context.md "$VAULT/_claude-brain/projects/$PROJECT/"
cp templates/obsidian/decision-log.md    "$VAULT/_claude-brain/projects/$PROJECT/"
cp templates/obsidian/architecture.md   "$VAULT/_claude-brain/projects/$PROJECT/"
```

Edite o `project-context.md` com as informações iniciais do projeto.

## Dicas

- Use o Obsidian normalmente para ver e editar as notas — o Claude escreve Markdown puro
- O plugin **Dataview** do Obsidian pode criar dashboards com as decisões de todos os projetos
- Adicione `_claude-brain/` ao `.gitignore` se não quiser versionar (ou versione — é só Markdown)
