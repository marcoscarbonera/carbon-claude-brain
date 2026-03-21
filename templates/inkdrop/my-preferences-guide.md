# Minhas Preferências de Desenvolvimento

> Este arquivo é carregado automaticamente pelo Claude Code em **toda sessão**, independente do projeto. Use para definir suas preferências pessoais, convenções e padrões que devem ser seguidos sempre.

## ⚠️ IMPORTANTE: Economia de Tokens

**Contexto carregado consome tokens a cada sessão!**

✅ **Seja CONCISO e OBJETIVO**
- Use bullet points, NÃO parágrafos longos
- Máximo 500-1000 linhas TOTAL em todas as notas `#claude-preferencia`
- Foque no "o quê", não no "por quê"
- Exemplos curtos (3-5 linhas)

❌ **Evite desperdiçar tokens:**
- Não escreva ensaios
- Não explique conceitos básicos
- Não repita informação

**Exemplo:**
- ❌ Ruim: "Eu sempre prefiro usar TypeScript porque..." (300 palavras)
- ✅ Bom: "TypeScript strict mode sempre"

---

## 🎯 Preferências Gerais

### Linguagem e Comunicação
- [ ] Sempre responda em português
- [ ] Use linguagem técnica mas acessível
- [ ] Explique decisões complexas antes de implementar

### Estilo de Código
- [ ] Prefiro **TypeScript** sempre que possível
- [ ] Usar **single quotes** (`'`) em JavaScript/TypeScript
- [ ] Indentação: **2 espaços** (não tabs)
- [ ] Sempre incluir ponto e vírgula (`;`)
- [ ] Preferir `const` sobre `let`, evitar `var`

### Async/Promises
- [ ] Preferir **async/await** em vez de `.then()/.catch()`
- [ ] Sempre tratar erros com try/catch em funções async
- [ ] Nunca usar callbacks quando Promise está disponível

### Imports/Exports
- [ ] Preferir **named exports** em vez de default exports
- [ ] Organizar imports: built-in → externos → internos → relativos
- [ ] Um import por linha (não usar vírgulas)

---

## 📝 Commits e Git

### Conventional Commits
- [ ] **Sempre** usar Conventional Commits
- [ ] Formato: `type(scope): description`
- [ ] Tipos permitidos:
  - `feat:` → Nova feature
  - `fix:` → Bug fix
  - `docs:` → Documentação
  - `style:` → Formatação (não afeta código)
  - `refactor:` → Refatoração
  - `test:` → Adicionar/modificar testes
  - `chore:` → Manutenção, build, deps

### Mensagens de Commit
- [ ] Primeira linha: máximo 72 caracteres
- [ ] Usar verbo no imperativo: "add" não "added" ou "adds"
- [ ] Não terminar com ponto final
- [ ] Corpo do commit: explicar "why", não "what"

**Exemplos bons:**
```
feat(auth): add JWT token refresh mechanism
fix(api): prevent memory leak in WebSocket connections
docs(readme): update installation instructions
```

**Exemplos ruins:**
```
Fixed bug
Updated files
WIP
changes
```

---

## 🧪 Testes

### Quando escrever testes
- [ ] **Sempre** escrever testes para features novas
- [ ] Priorizar testes de integração sobre unitários
- [ ] Testar edge cases e error handling
- [ ] Não testar código trivial (getters/setters simples)

### Estrutura de Testes
- [ ] Usar padrão **AAA** (Arrange, Act, Assert)
- [ ] Nomes descritivos: `should [expected behavior] when [condition]`
- [ ] Um conceito por teste
- [ ] Evitar lógica complexa em testes

**Exemplo:**
```javascript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user with hashed password when valid data provided', async () => {
      // Arrange
      const userData = { email: 'test@example.com', password: 'secret' };

      // Act
      const user = await userService.createUser(userData);

      // Assert
      expect(user.password).not.toBe('secret');
      expect(user.password).toHaveLength(60); // bcrypt hash
    });
  });
});
```

---

## 🏗️ Arquitetura e Padrões

### Estrutura de Pastas
- [ ] Preferir organização por **feature** em vez de tipo
- [ ] Colocar testes ao lado do código (`user.service.ts` + `user.service.test.ts`)
- [ ] Evitar pastas genéricas como `utils/` ou `helpers/`

**Exemplo:**
```
src/
├── users/
│   ├── user.service.ts
│   ├── user.service.test.ts
│   ├── user.controller.ts
│   └── user.types.ts
├── auth/
│   ├── auth.service.ts
│   ├── auth.middleware.ts
│   └── auth.types.ts
```

### Error Handling
- [ ] Sempre criar **error classes customizadas**
- [ ] Centralizar handling de erros (middleware/interceptor)
- [ ] Logar erros com contexto suficiente
- [ ] Nunca expor stack traces em produção

### API Design
- [ ] Seguir REST conventions (GET, POST, PUT, DELETE)
- [ ] Usar status codes corretos (200, 201, 400, 401, 404, 500)
- [ ] Versionamento de API: `/api/v1/...`
- [ ] Sempre validar input com biblioteca (Zod, Yup, class-validator)

---

## 📚 Documentação

### Código
- [ ] Documentar funções públicas com **JSDoc**
- [ ] Não comentar código óbvio
- [ ] Comentar apenas "why", não "what"
- [ ] Manter comentários atualizados ou remover

**Exemplo:**
```typescript
/**
 * Calcula o score de relevância de um documento baseado em TF-IDF.
 *
 * @param document - Texto do documento a ser analisado
 * @param corpus - Array de documentos para comparação
 * @returns Score entre 0 e 1, onde 1 é mais relevante
 * @throws {ValidationError} Se document estiver vazio
 */
function calculateRelevanceScore(document: string, corpus: string[]): number {
  // ...
}
```

### README
- [ ] Todo projeto deve ter README.md
- [ ] Incluir: descrição, instalação, uso, testes
- [ ] Manter atualizado com mudanças importantes

---

## 🔒 Segurança

### Credenciais
- [ ] **NUNCA** commitar credenciais, API keys, secrets
- [ ] Usar variáveis de ambiente (`.env` no `.gitignore`)
- [ ] Validar e sanitizar todo input de usuário
- [ ] Usar HTTPS em produção sempre

### Dependencies
- [ ] Revisar dependências antes de adicionar
- [ ] Preferir bibliotecas bem mantidas e populares
- [ ] Rodar `npm audit` / `yarn audit` regularmente
- [ ] Manter dependências atualizadas

---

## 🚀 Performance

### Otimizações
- [ ] **Não otimizar prematuramente** - medir primeiro
- [ ] Usar lazy loading quando apropriado
- [ ] Cachear operações caras (DB queries, APIs externas)
- [ ] Implementar rate limiting em APIs públicas

### Database
- [ ] Sempre adicionar índices em colunas de busca frequente
- [ ] Usar paginação para listagens grandes
- [ ] Evitar N+1 queries (usar eager loading)
- [ ] Preferir queries específicas sobre `SELECT *`

---

## 🛠️ Ferramentas e Workflow

### Linters/Formatters
- [ ] Usar **ESLint** com configuração strict
- [ ] Usar **Prettier** para formatação automática
- [ ] Configurar pre-commit hooks (Husky + lint-staged)

### CI/CD
- [ ] Rodar testes em todo PR
- [ ] Lint e type check em todo PR
- [ ] Build deve falhar se warnings
- [ ] Deploy automático após merge na main

---

## 💡 Notas Pessoais

### Padrões que eu gosto
- Prefiro Railway Oriented Programming para error handling
- Gosto de usar Result<T, E> types em vez de exceptions
- Valorizo código autodocumentado sobre comentários
- Preferir composição sobre herança

### Coisas a evitar
- Evitar God Objects / God Classes
- Não usar magic numbers/strings
- Não fazer mutações desnecessárias
- Evitar código clever demais - simplicidade > inteligência

### Filosofia
> "Make it work, make it right, make it fast — nessa ordem"

> "Código é lido 10x mais do que escrito - priorize legibilidade"

> "Se você precisa comentar, talvez o código deva ser refatorado"

---

**Última atualização:** {{date}}

**Nota:** Estas preferências são carregadas automaticamente pelo `session-start.sh`. Edite este arquivo para adicionar/modificar suas convenções pessoais.
