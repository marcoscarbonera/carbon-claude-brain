---
name: brain-plan
description: >
  Cria ou atualiza o plano do projeto em project-context.md.
  Use ao iniciar novo projeto ou quando arquitetura mudar.
---

# /brain-plan — Criar/Atualizar Plano do Projeto

Cria ou atualiza o arquivo `project-context.md` do projeto atual.

## O que contém

O `project-context.md` deve ter:

1. **Visão Geral** - O que é o projeto
2. **Stack Tecnológica** - Linguagens, frameworks, bibliotecas
3. **Arquitetura** - Estrutura de pastas, módulos principais
4. **Convenções** - Padrões de código, nomenclatura
5. **Decisões** - Escolhas arquiteturais importantes

## Implementação

```bash
#!/usr/bin/env bash
source ~/.claude/hooks/lib-carbon-brain.sh
load_config

PROJECT="$(basename "$(pwd)")"
PROJECT_DIR="$OBSIDIAN_VAULT/_claude-brain/projects/$PROJECT"
CONTEXT_FILE="$PROJECT_DIR/project-context.md"

# Criar diretório se não existir
mkdir -p "$PROJECT_DIR"

# Se arquivo já existe, perguntar se quer sobrescrever
if [ -f "$CONTEXT_FILE" ]; then
  echo "⚠️  project-context.md já existe para '$PROJECT'"
  echo ""
  echo "Deseja:"
  echo "  1) Ver contexto atual"
  echo "  2) Atualizar (sobrescrever)"
  echo "  3) Cancelar"
  echo ""
  read -p "Escolha (1-3): " choice

  case $choice in
    1)
      cat "$CONTEXT_FILE"
      exit 0
      ;;
    2)
      echo "Atualizando contexto..."
      ;;
    3)
      echo "Cancelado."
      exit 0
      ;;
    *)
      echo "Opção inválida. Cancelado."
      exit 1
      ;;
  esac
fi

# Template do project-context.md
cat > "$CONTEXT_FILE" << 'TEMPLATE'
---
project: {{PROJECT_NAME}}
created: {{DATE}}
updated: {{DATE}}
tags: [project-context]
---

# {{PROJECT_NAME}}

## Visão Geral

[Descrição breve do projeto - 2-3 linhas]

## Stack Tecnológica

**Linguagens:**
- [ex: TypeScript, Python, Go]

**Frameworks:**
- [ex: React, Express, FastAPI]

**Bibliotecas principais:**
- [ex: zod, prisma, axios]

**Infraestrutura:**
- [ex: Docker, PostgreSQL, Redis]

## Arquitetura

```
src/
├── components/     # Componentes React
├── services/       # Lógica de negócio
├── api/           # Rotas e controllers
├── models/        # Modelos de dados
└── utils/         # Utilitários
```

## Convenções de Código

- **Nomenclatura:** camelCase para variáveis, PascalCase para componentes
- **Imports:** Absolutos usando `@/` alias
- **Testes:** `*.test.ts` co-localizados com código
- **Commits:** Conventional Commits (feat, fix, docs, etc)

## Decisões Arquiteturais

### Gerenciamento de Estado
- [ex: Zustand ao invés de Redux - mais simples, menos boilerplate]

### Autenticação
- [ex: JWT com refresh tokens, expiração 15min/7dias]

### Database
- [ex: Prisma ORM - type-safety e migrations fáceis]

## Próximos Passos

- [ ] [Tarefa 1]
- [ ] [Tarefa 2]
- [ ] [Tarefa 3]

## Links Úteis

- Repo: [URL]
- Docs: [URL]
- Figma: [URL]
TEMPLATE

# Substituir placeholders
sed -i.bak "s/{{PROJECT_NAME}}/$PROJECT/g" "$CONTEXT_FILE"
sed -i.bak "s/{{DATE}}/$(date '+%Y-%m-%d')/g" "$CONTEXT_FILE"
rm "$CONTEXT_FILE.bak" 2>/dev/null

echo "✅ Contexto criado: $CONTEXT_FILE"
echo ""
echo "📝 Próximo passo: edite o arquivo e preencha os detalhes do projeto"
echo "   Abra em: $CONTEXT_FILE"
echo ""
```

## Template completo

```markdown
---
project: my-app
created: 2026-03-22
updated: 2026-03-22
tags: [project-context]
---

# my-app

## Visão Geral

API REST para gerenciamento de tarefas com autenticação JWT e real-time updates.

## Stack Tecnológica

**Linguagens:**
- TypeScript 5.x
- Node.js 20.x

**Frameworks:**
- Express 4.x
- Prisma 5.x
- Socket.io 4.x

**Bibliotecas principais:**
- zod (validação)
- bcrypt (hashing)
- jsonwebtoken (JWT)

**Infraestrutura:**
- Docker + Docker Compose
- PostgreSQL 15
- Redis 7

## Arquitetura

\`\`\`
src/
├── api/
│   ├── routes/       # Definição de rotas
│   ├── controllers/  # Handlers das rotas
│   └── middlewares/  # Auth, validation, etc
├── services/         # Lógica de negócio
├── models/          # Tipos TypeScript
├── db/              # Prisma schema e migrations
└── utils/           # Helpers e utilities
\`\`\`

## Convenções de Código

- **Nomenclatura:** camelCase variáveis, PascalCase tipos/interfaces
- **Imports:** Absolutos com alias `@/`
- **Error handling:** Classe AppError customizada
- **Validação:** Zod schemas em `schemas/`

## Decisões Arquiteturais

### Autenticação
- JWT com access token (15min) + refresh token (7 dias)
- Refresh tokens armazenados no Redis
- Rotação de refresh tokens a cada uso

### Real-time
- Socket.io para updates de tarefas
- Redis adapter para múltiplas instâncias

### Validação
- Zod para runtime validation
- TypeScript para compile-time safety
- Schemas reutilizáveis

## Próximos Passos

- [ ] Implementar rate limiting
- [ ] Adicionar testes de integração
- [ ] Setup CI/CD pipeline
```

## Quando usar

- **Início de novo projeto**
- Quando **arquitetura mudar** significativamente
- Ao adicionar **nova stack** tecnológica
- Para **documentar decisões** arquiteturais
- Quando novo desenvolvedor entrar no projeto

## Arquivos relacionados

- `project-context.md` - Visão geral (este comando cria)
- `decision-log.md` - Log de decisões (use /brain-save para adicionar)
- `architecture.md` - Detalhes técnicos aprofundados (opcional)
