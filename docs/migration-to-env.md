# Migração de `config` para `.env`

> A partir da versão 0.2.0, o carbon-claude-brain usa `.env` em vez de `config` para credenciais.

---

## Por que a mudança?

### ✅ Vantagens do `.env`

1. **Padrão universal** - Formato reconhecido por Docker, Node.js, Python, etc.
2. **Melhor segurança** - Desenvolvedores sabem que `.env` contém credenciais
3. **Compatibilidade** - Funciona com ferramentas como `dotenv`, `docker-compose`
4. **Mais explícito** - Comentários no arquivo alertam "DO NOT COMMIT"
5. **Listado no .gitignore automaticamente** - Menos risco de commit acidental

### Formato `.env` vs `config` bash

**Antes (`config`):**
```bash
OBSIDIAN_VAULT="/caminho"
INKDROP_URL="http://localhost:19840"
INKDROP_USER="usuario"
INKDROP_PASS="senha"
```

**Agora (`.env`):**
```bash
# carbon-claude-brain configuration
# DO NOT COMMIT THIS FILE

OBSIDIAN_VAULT="/caminho"
INKDROP_URL="http://localhost:19840"
INKDROP_USER="usuario"
INKDROP_PASS="senha"
```

**Diferença:** Mesmo formato! Apenas adiciona comentários e nome mais padrão.

---

## Como migrar?

### Opção 1: Reinstalar (recomendado)

```bash
cd /caminho/do/carbon-claude-brain
./uninstall.sh
./install.sh
```

O novo `install.sh` já cria `.env` automaticamente.

### Opção 2: Migração manual

```bash
# Copiar config antigo para .env
cp ~/.carbon-brain/config ~/.carbon-brain/.env

# Adicionar comentários (opcional)
cat > ~/.carbon-brain/.env <<'EOF'
# carbon-claude-brain configuration
# DO NOT COMMIT THIS FILE

EOF

# Adicionar variáveis antigas
cat ~/.carbon-brain/config >> ~/.carbon-brain/.env

# Verificar permissões
chmod 600 ~/.carbon-brain/.env

# Manter config antigo para compatibilidade (opcional)
# ou remover se quiser
# rm ~/.carbon-brain/config
```

### Opção 3: Não fazer nada

**Compatibilidade retroativa garantida!**

Se você já tem `~/.carbon-brain/config`, ele continua funcionando. Os hooks verificam:
1. Primeiro: procura `.env`
2. Se não encontrar: usa `config` antigo

Você pode migrar quando quiser, sem pressa.

---

## Verificar se está usando `.env`

```bash
# Ver qual arquivo está sendo usado
ls -la ~/.carbon-brain/

# Se tiver .env, está usando o novo formato
# Se tiver apenas config, está usando formato antigo (ainda funciona)
```

---

## `.env` no .gitignore

O arquivo `.gitignore` do projeto já inclui:

```gitignore
# ── Configurações locais (contém credenciais) ──────────────────────
.env
.env.*
*.env
.env.local
.env.production
config.local
config
.carbon-brain/
```

Isso garante que você **nunca** vai commitar credenciais acidentalmente.

---

## Usar `.env` com outras ferramentas

### Docker Compose

Se você quiser reutilizar as mesmas credenciais:

```yaml
# docker-compose.yml
version: '3'
services:
  app:
    env_file:
      - ~/.carbon-brain/.env
```

### Node.js com dotenv

```javascript
// index.js
require('dotenv').config({ path: '~/.carbon-brain/.env' });

console.log(process.env.INKDROP_URL);
// http://localhost:19840
```

### Python com python-dotenv

```python
# script.py
from dotenv import load_dotenv
import os

load_dotenv('~/.carbon-brain/.env')

print(os.getenv('INKDROP_URL'))
# http://localhost:19840
```

---

## Perguntas Frequentes

### Q: Preciso migrar agora?
**R:** Não. Compatibilidade com `config` antigo é mantida indefinidamente.

### Q: O que acontece se eu tiver os dois arquivos?
**R:** `.env` tem prioridade. `config` é ignorado.

### Q: Posso usar variáveis de ambiente do sistema?
**R:** Sim! Se definir `export INKDROP_URL=...` no shell, `.env` sobrescreve.

### Q: Como adicionar novas variáveis?
**R:** Edite `~/.carbon-brain/.env` e adicione:
```bash
NOVA_VARIAVEL="valor"
```

### Q: `.env` funciona no Windows?
**R:** Sim, desde que use WSL ou Git Bash.

### Q: Posso ter múltiplos `.env` (produção, dev)?
**R:** Não recomendado. carbon-brain usa apenas um. Mas você pode:
```bash
cp ~/.carbon-brain/.env ~/.carbon-brain/.env.backup
cp ~/.carbon-brain/.env.trabalho ~/.carbon-brain/.env
```

---

## Segurança

### ✅ Faça

- Mantenha `chmod 600` no `.env`
- Adicione `.env` ao `.gitignore` (já está)
- Use senhas diferentes para Inkdrop local vs Cloud
- Revise `.env` periodicamente

### ❌ Não faça

- Nunca commite `.env` no git
- Nunca compartilhe `.env` por Slack/email
- Não use senhas fracas
- Não deixe `.env` em backups públicos

---

## Rollback (voltar para `config`)

Se quiser voltar ao formato antigo:

```bash
# Remover .env
rm ~/.carbon-brain/.env

# Manter apenas config
# (os hooks vão detectar e usar automaticamente)
```

---

## Changelog

**v0.2.0 (2024-03-21)**
- ✅ Introduzido `.env` como formato padrão
- ✅ Mantida compatibilidade com `config` antigo
- ✅ Criada biblioteca `lib-carbon-brain.sh` para código compartilhado
- ✅ Função `load_config()` detecta automaticamente qual arquivo usar

---

**Dúvidas?** Veja [docs/troubleshooting.md](troubleshooting.md)
