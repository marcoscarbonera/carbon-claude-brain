# Otimização de Tokens — Guia Rápido

> Como manter o carbon-claude-brain eficiente e não desperdiçar tokens

---

## 📊 Entendendo o Consumo

### Contexto carregado a cada sessão:

```
Preferências pessoais (Inkdrop)        ~500-2000 tokens
Contexto do projeto (Obsidian)         ~300-1000 tokens
Decisões recentes (últimas 20)         ~200-500 tokens
Último journal (Inkdrop)               ~100-300 tokens
─────────────────────────────────────────────────────────
TOTAL POR SESSÃO:                      ~1100-3800 tokens
```

### Quando vale a pena?

| Cenário | Consumo sem brain | Consumo com brain | Economia |
|---------|-------------------|-------------------|----------|
| **Script rápido (3 msgs)** | 500 tokens | 2000 tokens | ❌ -300% |
| **Implementação média (10 msgs)** | 2000 tokens | 2500 tokens | ⚖️ -25% |
| **Projeto complexo (20+ msgs)** | 5000 tokens | 4000 tokens | ✅ +20% |
| **Projeto recorrente (voltando depois de semanas)** | 3000 tokens | 2500 tokens | ✅ +15% |

**Conclusão:** Quanto mais longa/complexa a sessão, maior a economia.

---

## 🚀 Como Otimizar

### 1. Desabilitar para Projetos Pequenos

```bash
# Projeto rápido? Desabilite o contexto
CARBON_BRAIN_SKIP=1 claude

# Volta ao normal automaticamente
cd /outro-projeto
claude  # Contexto carregado normalmente
```

### 2. Manter Preferências Concisas

#### ❌ RUIM - Desperdiça ~1500 tokens

```markdown
Título: Minhas Preferências de TypeScript
Tags: #claude-preferencia

# TypeScript

Eu sempre prefiro usar TypeScript em todos os meus projetos porque
acredito que a tipagem estática traz muitos benefícios. O autocomplete
fica melhor, os bugs diminuem em produção, e o refactoring fica mais
seguro. Por isso, sempre que possível, escolho TypeScript.

Além disso, eu gosto muito de configurar o tsconfig.json com strict
mode ativado. Isso força o compilador a ser mais rigoroso e me ajuda
a escrever código melhor. Eu também prefiro usar interfaces para
objetos porque elas são mais extensíveis...

(continua por 500 linhas)
```

#### ✅ BOM - Apenas ~100 tokens

```markdown
Título: Dev Preferences
Tags: #claude-preferencia

## TypeScript
- Sempre usar TS (não JS)
- strict: true no tsconfig
- interface para objetos
- type para unions

## Commits
- Conventional Commits
- Max 72 chars

## Tests
- AAA pattern
- Nome: should [behavior] when [condition]
```

**Economia:** ~1400 tokens por sessão! 🎉

### 3. Limitar Número de Notas

```
❌ 10 notas com #claude-preferencia = ~5000 tokens
✅ 2-3 notas concisas = ~500-1000 tokens
```

**Recomendação:**
- 1 nota de preferências gerais
- 1 nota de code style (se necessário)
- 1 nota de stack específica (se necessário)
- **MÁXIMO 3 notas**

### 4. Usar Exemplos Curtos

#### ❌ RUIM - Exemplo longo

```markdown
## Error Handling

Exemplo de como criar custom errors:

\`\`\`typescript
// errors/ValidationError.ts
export class ValidationError extends Error {
  constructor(
    message: string,
    public field: string,
    public value: unknown,
    public constraints: Record<string, string>
  ) {
    super(message);
    this.name = 'ValidationError';
    Error.captureStackTrace(this, this.constructor);
  }

  toJSON() {
    return {
      name: this.name,
      message: this.message,
      field: this.field,
      value: this.value,
      constraints: this.constraints
    };
  }
}

// Usage example
import { ValidationError } from './errors/ValidationError';

function validateEmail(email: string) {
  if (!email.includes('@')) {
    throw new ValidationError(
      'Invalid email format',
      'email',
      email,
      { format: 'must contain @' }
    );
  }
}
\`\`\`
```

#### ✅ BOM - Exemplo curto

```markdown
## Error Handling

Custom errors:
\`\`\`ts
class ValidationError extends Error {
  constructor(msg: string, public field: string) {
    super(msg);
  }
}
\`\`\`
```

**Economia:** ~300 tokens

---

## 📝 Checklist de Otimização

### Para Preferências Pessoais

- [ ] Usei bullet points (não parágrafos)?
- [ ] Cada nota tem < 300 linhas?
- [ ] Total de notas `#claude-preferencia` < 3?
- [ ] Removi explicações óbvias?
- [ ] Exemplos de código têm < 10 linhas?
- [ ] Total geral < 1000 linhas?

### Para Decision Logs

- [ ] Cada decisão tem < 10 linhas?
- [ ] Formato: Contexto → Decisão → Motivo?
- [ ] Removi discussões longas?

### Para Journals

- [ ] Resumo objetivo (não narrativa)?
- [ ] Máximo 200 palavras?
- [ ] Apenas o essencial documentado?

---

## 🎯 Metas de Tamanho

| Tipo | Tamanho Ideal | Máximo Aceitável |
|------|---------------|------------------|
| **Nota de preferência** | 100-200 linhas | 300 linhas |
| **Total preferências** | 300-500 linhas | 1000 linhas |
| **Decision log (por decisão)** | 3-5 linhas | 10 linhas |
| **Journal (por sessão)** | 100-150 palavras | 300 palavras |
| **Exemplo de código** | 3-5 linhas | 10 linhas |

---

## 🔧 Ferramentas de Verificação

### Ver tamanho das suas notas

```bash
# Obsidian
wc -l "$OBSIDIAN_VAULT/_claude-brain/projects/"*/decision-log.md

# Inkdrop (via API)
source ~/.carbon-brain/config
curl -s -u "$INKDROP_USER:$INKDROP_PASS" \
  "$INKDROP_URL/notes?keyword=claude-preferencia" | \
  jq '.items[] | {title, size: (.body | length)}'
```

### Estimar tokens

**Regra aproximada:**
- 1 palavra inglesa ≈ 1.3 tokens
- 1 palavra portuguesa ≈ 1.5 tokens
- 1 linha de código ≈ 3-5 tokens

**Calculadora:**
```bash
# Contar palavras
wc -w arquivo.md

# Estimar tokens (inglês)
echo "$(wc -w < arquivo.md) * 1.3" | bc

# Estimar tokens (português)
echo "$(wc -w < arquivo.md) * 1.5" | bc
```

---

## 📈 Exemplo de Otimização Real

### Antes (❌ ~3500 tokens por sessão)

```
Preferências:
├── my-preferences.md (1500 linhas)      ~4000 tokens
├── code-style.md (2000 linhas)          ~5000 tokens
├── react-guide.md (800 linhas)          ~2000 tokens
└── python-guide.md (600 linhas)         ~1500 tokens
─────────────────────────────────────────────────────────
TOTAL carregado:                         ~12500 tokens ❌
```

### Depois (✅ ~800 tokens por sessão)

```
Preferências:
├── core-preferences.md (200 linhas)     ~500 tokens
└── code-style.md (150 linhas)           ~400 tokens
─────────────────────────────────────────────────────────
TOTAL carregado:                         ~900 tokens ✅
```

**Economia:** ~11600 tokens por sessão = **~92% de redução!** 🚀

---

## 💡 Dicas Finais

1. **Revise suas preferências mensalmente** - Remova o que não usa mais
2. **Comece pequeno** - Adicione preferências conforme necessita
3. **Teste o impacto** - Use `CARBON_BRAIN_SKIP=1` para comparar
4. **Priorize qualidade** - 10 regras bem escolhidas > 100 regras genéricas
5. **Use bom senso** - Contexto útil compensa tokens, contexto inútil desperdiça

---

## 🆘 Precisa de Ajuda?

Se suas sessões estão ficando muito caras em tokens:

1. Rode `/carbon-brain-test` e veja o que está sendo carregado
2. Revise suas notas `#claude-preferencia` no Inkdrop
3. Considere usar `CARBON_BRAIN_SKIP=1` para projetos simples
4. Leia: [docs/setup-personal-preferences.md](setup-personal-preferences.md)

**Lembre-se:** O objetivo é **ajudar**, não **atrapalhar**. Se está desperdiçando tokens, simplifique! 🎯
