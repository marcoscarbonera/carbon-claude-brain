# Contribuindo para o carbon-claude-brain

Obrigado pelo interesse em contribuir! Este documento contém as diretrizes para contribuições.

## Código de Conduta

Este projeto adere ao [Código de Conduta](CODE_OF_CONDUCT.md). Ao participar, você concorda em seguir suas diretrizes.

## Como Contribuir

### Reportando Bugs

Antes de reportar um bug:
- Verifique se já não existe uma issue aberta sobre o problema
- Use a versão mais recente do projeto
- Teste com uma instalação limpa

Ao reportar, inclua:
- Descrição clara do problema
- Passos para reproduzir
- Comportamento esperado vs. atual
- Versões (Claude Code, macOS/Linux, Obsidian, Inkdrop)
- Logs relevantes (remova informações sensíveis)

### Sugerindo Melhorias

- Abra uma issue descrevendo a sugestão
- Explique o problema que ela resolve
- Descreva a solução proposta
- Considere alternativas

### Pull Requests

#### Fluxo de Trabalho

1. **Fork o repositório**
2. **Crie uma branch** a partir da `main`:
   ```bash
   git checkout -b feature/minha-feature
   # ou
   git checkout -b fix/meu-bugfix
   ```

3. **Faça suas alterações**
   - Siga o estilo do código existente
   - Mantenha os commits atômicos e bem descritos
   - Teste suas mudanças localmente

4. **Commit seguindo Conventional Commits**:
   ```bash
   git commit -m "feat: adiciona suporte para vault remoto"
   git commit -m "fix: corrige leitura de credenciais do Inkdrop"
   git commit -m "docs: atualiza setup do Obsidian"
   ```

5. **Push para seu fork**:
   ```bash
   git push origin feature/minha-feature
   ```

6. **Abra um Pull Request** para a branch `main`

#### Convenção de Commits

Usamos [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` nova funcionalidade
- `fix:` correção de bug
- `docs:` apenas documentação
- `style:` formatação, ponto e vírgula, etc
- `refactor:` refatoração de código
- `test:` adição de testes
- `chore:` atualização de build, configs, etc

#### Checklist do PR

- [ ] Código segue o estilo do projeto
- [ ] Commits seguem Conventional Commits
- [ ] Documentação atualizada (se necessário)
- [ ] Testado localmente
- [ ] Não quebra funcionalidades existentes
- [ ] Não expõe credenciais ou dados sensíveis

### Proteção da Branch Main

A branch `main` é protegida e requer:
- Review de pelo menos 1 mantenedor
- Status checks passando (CI)
- Branch atualizada com a `main`
- Commits assinados (recomendado)

**Não é possível fazer push direto para a `main`**. Todo código deve entrar via Pull Request.

## Estrutura do Projeto

```
carbon-claude-brain/
├── hooks/              # Hooks do Claude Code
├── skills/             # Skills para o Claude
├── templates/          # Templates de notas
├── docs/               # Documentação adicional
├── .github/            # Templates de issues/PRs e workflows
└── install.sh          # Script de instalação
```

## Testando Localmente

1. Clone seu fork
2. Execute `./install.sh` em um ambiente de teste
3. Configure Obsidian e Inkdrop para teste
4. Teste o fluxo completo:
   - Início de sessão
   - Uso das skills
   - Fim de sessão

## Diretrizes de Código

### Shell Scripts

- Use `#!/usr/bin/env bash` no shebang
- Use `set -e` para falhar em erros
- Valide entradas do usuário
- Nunca exponha credenciais em logs
- Comente código complexo
- Use variáveis em MAIÚSCULAS para configuração

### Markdown

- Use headings corretos (# ## ###)
- Inclua code blocks com syntax highlighting
- Mantenha linhas com no máximo 120 caracteres (quando possível)
- Use listas para melhor legibilidade

### Documentação

- Toda nova feature precisa de documentação
- Atualize o README.md se necessário
- Inclua exemplos práticos
- Mantenha o português-BR consistente

## Segurança

- **Nunca commite credenciais**
- Use `~/.carbon-brain/config` para dados sensíveis
- Revise PRs para vazamento acidental de secrets
- Reporte vulnerabilidades via [SECURITY.md](SECURITY.md)

## Dúvidas?

- Abra uma issue com a tag `question`
- Seja específico e claro na pergunta
- Verifique se não foi perguntado antes

## Licença

Ao contribuir, você concorda que suas contribuições serão licenciadas sob a mesma licença MIT do projeto.
