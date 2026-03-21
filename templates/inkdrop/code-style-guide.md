# Guia de Estilo de Código

> Regras específicas de formatação e convenções de código. Este arquivo é carregado automaticamente em toda sessão.

## ⚠️ ATENÇÃO: Este é um TEMPLATE COMPLETO para referência

**NÃO copie tudo!** Este template tem ~2000 linhas e consumiria ~5000 tokens por sessão.

**Como usar:**
1. Leia as seções abaixo
2. Copie APENAS o que é relevante para você
3. Seja conciso - máximo 300-500 linhas na sua nota final
4. Use bullet points, não parágrafos

**Exemplo de nota concisa:**
```markdown
# Meu Code Style

## JavaScript/TypeScript
- PascalCase: classes
- camelCase: funções/vars
- UPPER_SNAKE_CASE: constants
- Preferir arrow functions
- async/await sempre

## React
- Hooks no topo
- useCallback para event handlers
- Key em listas sempre
```
(Total: ~100 tokens em vez de 5000)

---

## JavaScript / TypeScript

### Naming Conventions

```typescript
// Classes: PascalCase
class UserService {}
class ApiController {}

// Functions/Variables: camelCase
function calculateTotal() {}
const userName = 'John';

// Constants: UPPER_SNAKE_CASE
const API_BASE_URL = 'https://api.example.com';
const MAX_RETRIES = 3;

// Interfaces/Types: PascalCase com prefixo I (opcional)
interface User {}
interface IUserRepository {} // se preferir prefixo
type ApiResponse<T> = { data: T; status: number };

// Enums: PascalCase (keys também)
enum UserRole {
  Admin = 'ADMIN',
  User = 'USER',
  Guest = 'GUEST'
}

// Private members: _ prefix (opcional)
class Example {
  private _internalState: number;
}
```

### Function Declaration

```typescript
// ✅ Preferir arrow functions para callbacks
const numbers = [1, 2, 3];
const doubled = numbers.map(n => n * 2);

// ✅ Async/await sempre
async function fetchUser(id: string): Promise<User> {
  try {
    const response = await api.get(`/users/${id}`);
    return response.data;
  } catch (error) {
    throw new ApiError('Failed to fetch user', error);
  }
}

// ❌ Evitar .then()
function fetchUserBad(id: string): Promise<User> {
  return api.get(`/users/${id}`)
    .then(response => response.data)
    .catch(error => {
      throw new ApiError('Failed to fetch user', error);
    });
}

// ✅ Destructuring em parâmetros
function createUser({ name, email, age }: CreateUserDto) {
  // ...
}

// ❌ Evitar muitos parâmetros posicionais
function createUserBad(name: string, email: string, age: number, phone: string) {
  // ...
}
```

### Type Annotations

```typescript
// ✅ Sempre anotar tipos de retorno de funções públicas
export function calculateTax(amount: number): number {
  return amount * 0.2;
}

// ✅ Anotar parâmetros sempre
function process(data: string, options: ProcessOptions): void {
  // ...
}

// ✅ Usar types para objetos complexos
type User = {
  id: string;
  name: string;
  email: string;
  createdAt: Date;
};

// ✅ Usar interface para objetos extensíveis
interface ApiClient {
  get<T>(url: string): Promise<T>;
  post<T>(url: string, data: unknown): Promise<T>;
}

// ✅ Preferir union types sobre enums quando possível
type Status = 'pending' | 'approved' | 'rejected';
```

### Error Handling

```typescript
// ✅ Custom error classes
class ValidationError extends Error {
  constructor(
    message: string,
    public field: string,
    public value: unknown
  ) {
    super(message);
    this.name = 'ValidationError';
  }
}

// ✅ Try/catch em async functions
async function saveUser(user: User): Promise<void> {
  try {
    await db.users.insert(user);
  } catch (error) {
    if (error instanceof UniqueConstraintError) {
      throw new ValidationError('Email already exists', 'email', user.email);
    }
    throw error; // Re-throw unknown errors
  }
}

// ✅ Result type pattern (opcional)
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

async function fetchUserSafe(id: string): Promise<Result<User>> {
  try {
    const user = await db.users.findById(id);
    return { ok: true, value: user };
  } catch (error) {
    return { ok: false, error: error as Error };
  }
}
```

---

## React / JSX

### Component Structure

```tsx
// ✅ Ordem preferida dentro de um componente:
// 1. Imports
// 2. Types/Interfaces
// 3. Component function
// 4. Hooks (useState, useEffect, custom hooks)
// 5. Event handlers
// 6. Helper functions
// 7. Render logic
// 8. Return JSX

import { useState, useEffect } from 'react';
import { Button } from './Button';

interface UserProfileProps {
  userId: string;
  onUpdate?: (user: User) => void;
}

export function UserProfile({ userId, onUpdate }: UserProfileProps) {
  // Hooks
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadUser();
  }, [userId]);

  // Event handlers
  const handleSave = async () => {
    // ...
  };

  // Helper functions
  const loadUser = async () => {
    // ...
  };

  // Early returns
  if (loading) return <div>Loading...</div>;
  if (!user) return <div>User not found</div>;

  // Main render
  return (
    <div className="user-profile">
      <h1>{user.name}</h1>
      <Button onClick={handleSave}>Save</Button>
    </div>
  );
}
```

### Hooks

```tsx
// ✅ Custom hooks: prefix "use"
function useUser(userId: string) {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    fetchUser(userId).then(setUser);
  }, [userId]);

  return user;
}

// ✅ Memoização quando necessário
const expensiveValue = useMemo(
  () => calculateExpensiveValue(data),
  [data]
);

// ✅ useCallback para event handlers passados como props
const handleClick = useCallback(() => {
  console.log('clicked');
}, []);

// ❌ Não usar useEffect para transformações síncronas
// Ruim:
useEffect(() => {
  setDoubled(value * 2);
}, [value]);

// Bom:
const doubled = value * 2;
```

### JSX

```tsx
// ✅ Componentes em PascalCase
<UserProfile userId="123" />

// ✅ Props boolean sem valor = true
<Button disabled />

// ✅ Preferir ternário em vez de && para condicional
{isLoading ? <Spinner /> : <Content />}

// ❌ Evitar && que pode retornar 0
{count && <div>{count} items</div>} // Ruim: mostra "0"
{count > 0 && <div>{count} items</div>} // Bom

// ✅ Fragments quando necessário
<>
  <Header />
  <Main />
</>

// ✅ Key em listas
{users.map(user => (
  <UserCard key={user.id} user={user} />
))}
```

---

## CSS / Styling

### Naming (BEM ou CSS Modules)

```css
/* BEM */
.user-profile { }
.user-profile__header { }
.user-profile__avatar { }
.user-profile__avatar--large { }

/* CSS Modules */
.container { }
.title { }
.button { }
```

### Ordem de Propriedades

```css
.element {
  /* 1. Positioning */
  position: absolute;
  top: 0;
  left: 0;
  z-index: 10;

  /* 2. Box Model */
  display: flex;
  width: 100%;
  height: 200px;
  margin: 10px;
  padding: 20px;

  /* 3. Typography */
  font-size: 16px;
  line-height: 1.5;
  color: #333;

  /* 4. Visual */
  background: white;
  border: 1px solid #ddd;
  border-radius: 4px;

  /* 5. Misc */
  opacity: 1;
  cursor: pointer;
  transition: all 0.3s ease;
}
```

---

## SQL / Database

### Query Style

```sql
-- ✅ Keywords em UPPERCASE
SELECT
  u.id,
  u.name,
  u.email,
  COUNT(o.id) AS order_count
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
WHERE u.active = TRUE
  AND u.created_at > '2024-01-01'
GROUP BY u.id, u.name, u.email
HAVING COUNT(o.id) > 0
ORDER BY order_count DESC
LIMIT 10;

-- ✅ Table aliases curtos e significativos
-- u = users, o = orders, p = products

-- ✅ Indentação clara
-- ❌ Evitar SELECT *
```

### Migrations

```sql
-- ✅ Sempre reversível
-- up.sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) NOT NULL UNIQUE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);

-- down.sql
DROP INDEX IF EXISTS idx_users_email;
DROP TABLE IF EXISTS users;
```

---

## Markdown

### Headers

```markdown
# H1 - Título do Documento

## H2 - Seções Principais

### H3 - Subseções

#### H4 - Detalhes

Não usar H5/H6 - reestruturar se necessário
```

### Code Blocks

````markdown
```typescript
// Sempre especificar a linguagem para syntax highlighting
const example = 'código aqui';
```
````

### Lists

```markdown
- Item não ordenado
- Outro item
  - Sub-item com 2 espaços de indentação

1. Item ordenado
2. Outro item
   1. Sub-item com 3 espaços de indentação
```

---

## Git

### Branches

```bash
# Naming convention
main                    # Branch principal
develop                 # Branch de desenvolvimento (opcional)
feature/user-auth       # Nova feature
fix/login-validation    # Bug fix
hotfix/critical-bug     # Fix urgente em produção
refactor/api-structure  # Refatoração
docs/readme-update      # Documentação
```

### Commits

```bash
# Conventional Commits
feat(auth): add social login with Google
fix(api): prevent race condition in order creation
docs(readme): update installation steps
style(components): apply prettier formatting
refactor(user): extract validation to separate module
test(auth): add integration tests for login flow
chore(deps): upgrade react to v18
```

---

## Outras Convenções

### Arquivo .env

```bash
# Comentários explicativos
# Database
DATABASE_URL=postgresql://localhost:5432/mydb
DATABASE_POOL_SIZE=10

# API Keys (nunca commitar valores reais)
STRIPE_API_KEY=sk_test_...
SENDGRID_API_KEY=SG.xxx

# Feature Flags
ENABLE_NEW_DASHBOARD=false

# SEMPRE adicionar .env.example com valores de exemplo
```

### package.json scripts

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "lint": "eslint .",
    "lint:fix": "eslint . --fix",
    "type-check": "tsc --noEmit"
  }
}
```

---

**Última atualização:** {{date}}
