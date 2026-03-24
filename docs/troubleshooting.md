# Troubleshooting — carbon-claude-brain

Guia para diagnosticar e resolver problemas comuns.

---

## 🔍 Como verificar se está funcionando

### 1. Verificar se hooks estão instalados

```bash
ls -la ~/.claude/hooks/ | grep carbon-brain
```

Você deve ver:
```
carbon-brain-start.sh
carbon-brain-end.sh
carbon-brain-post-tool.sh
```

### 2. Verificar se skills estão instaladas

```bash
ls -la ~/.claude/skills/
```

Você deve ver os diretórios:
```
brain/
obsidian/
inkdrop/
```

### 3. Verificar se hooks estão registrados

```bash
cat ~/.claude/settings.json | grep carbon-brain
```

Deve aparecer referências aos hooks nos arrays `PreToolUse`, `PostToolUse` e `Stop`.

### 4. Testar hook de session-start manualmente

```bash
cd /caminho/do/seu/projeto
bash ~/.claude/hooks/carbon-brain-start.sh
```

Deve mostrar o contexto carregado do Obsidian/Inkdrop (se existir).

### 5. Verificar configuração

```bash
cat ~/.carbon-brain/.env
```

Deve mostrar:
```bash
# carbon-claude-brain configuration
# DO NOT COMMIT THIS FILE

OBSIDIAN_VAULT="/caminho/do/vault"
INKDROP_URL="http://localhost:19840"
INKDROP_USER="seu_usuario"
INKDROP_PASS="sua_senha"
```

**Nota:** Se você instalou uma versão antiga, pode ter `~/.carbon-brain/config` em vez de `.env`. Ambos funcionam (compatibilidade retroativa).

---

## ❌ Problemas Comuns

### 1. Contexto não carrega ao iniciar Claude Code

**Sintomas:**
- Claude Code inicia mas não mostra mensagem de contexto carregado
- Nenhum erro visível

**Causas possíveis:**

#### A) Hook não está executando

**Verificar:**
```bash
# Ver se o hook está registrado
cat ~/.claude/settings.json | grep PreToolUse
```

**Solução:**
```bash
# Reinstalar
cd /caminho/do/carbon-claude-brain
./uninstall.sh
./install.sh
```

#### B) Projeto não tem contexto criado

**Verificar:**
```bash
PROJECT_NAME="$(basename $(pwd))"
ls -la "$OBSIDIAN_VAULT/_claude-brain/projects/$PROJECT_NAME/"
```

**Solução:**
```bash
# Criar contexto manualmente
mkdir -p "$OBSIDIAN_VAULT/_claude-brain/projects/$PROJECT_NAME"
cp templates/obsidian/*.md "$OBSIDIAN_VAULT/_claude-brain/projects/$PROJECT_NAME/"
```

#### C) Permissões incorretas

**Verificar:**
```bash
ls -la ~/.claude/hooks/carbon-brain-*.sh
```

Deve mostrar permissão de execução (`-rwx------` ou similar).

**Solução:**
```bash
chmod +x ~/.claude/hooks/carbon-brain-*.sh
```

### 2. Erro "curl: command not found"

**Causa:** curl não está instalado

**Solução:**
```bash
# macOS
brew install curl

# Linux (Debian/Ubuntu)
sudo apt-get install curl

# Linux (RedHat/CentOS)
sudo yum install curl
```

### 3. Erro ao salvar no Inkdrop

**Sintomas:**
- Comando `/carbon-brain-save` falha
- Erro de conexão com localhost:19840

**Causas possíveis:**

#### A) Servidor local do Inkdrop não está rodando

**Verificar:**
```bash
curl -u "$INKDROP_USER:$INKDROP_PASS" http://localhost:19840/notes
```

Se der erro de conexão, o servidor não está ativo.

**Solução:**
1. Abrir Inkdrop
2. Ir em: **Preferences > Integrations > Local REST API Server**
3. Clicar em "Start Server"
4. Verificar que porta é **19840** (padrão)

#### B) Credenciais incorretas

**Verificar:**
```bash
source ~/.carbon-brain/config
curl -u "$INKDROP_USER:$INKDROP_PASS" "$INKDROP_URL/notes"
```

Se retornar erro 401 Unauthorized, as credenciais estão erradas.

**Solução:**
```bash
# Reconfigurar
rm ~/.carbon-brain/config
./install.sh
```

#### C) Porta diferente

Inkdrop pode estar rodando em outra porta.

**Verificar:**
- No Inkdrop: **Preferences > Integrations > Local REST API Server**
- Verificar número da porta

**Solução:**
```bash
# Editar config
nano ~/.carbon-brain/config
# Alterar INKDROP_URL para a porta correta
```

### 4. Activity log crescendo muito

**Sintoma:**
```bash
du -h ~/.carbon-brain/activity.log
# 500M activity.log
```

**Solução:**
```bash
# Rotacionar manualmente
mv ~/.carbon-brain/activity.log ~/.carbon-brain/activity.log.old
touch ~/.carbon-brain/activity.log

# Ou limpar completamente
rm ~/.carbon-brain/activity.log
```

**Nota:** A rotação automática foi implementada na versão mais recente.

### 5. Erro "node: command not found"

**Causa:** Node.js não está instalado

**Solução:**
```bash
# macOS
brew install node

# Linux (Debian/Ubuntu)
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verificar instalação
node --version
```

### 6. Múltiplas sessões simultâneas sobrescrevem trigger

**Sintoma:**
- Dois Claude Code rodando no mesmo projeto
- Apenas um salva o resumo

**Causa:** Race condition no arquivo trigger

**Solução temporária:**
- Evitar rodar múltiplas sessões do Claude Code no mesmo projeto simultaneamente
- Ou salvar resumo manualmente: `/carbon-brain-save` antes de encerrar

**Nota:** Fix planejado para versão futura (usar PID único).

---

## 🐛 Debug Avançado

### Habilitar modo debug nos hooks

Adicione no início de cada hook (após `source ~/.carbon-brain/config`):

```bash
# Debug mode
set -x  # Print cada comando executado
exec 2>> ~/.carbon-brain/debug.log  # Log de erros
```

Exemplo em `session-start.sh`:

```bash
CONFIG="$HOME/.carbon-brain/config"
[ -f "$CONFIG" ] || exit 0
source "$CONFIG"

# Debug mode
set -x
exec 2>> ~/.carbon-brain/debug.log
```

Depois rode Claude Code e veja:
```bash
tail -f ~/.carbon-brain/debug.log
```

### Testar Inkdrop API manualmente

```bash
source ~/.carbon-brain/config

# Listar notas
curl -u "$INKDROP_USER:$INKDROP_PASS" "$INKDROP_URL/notes" | jq

# Criar nota de teste
curl -u "$INKDROP_USER:$INKDROP_PASS" \
  -X POST "$INKDROP_URL/notes" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Teste carbon-brain",
    "body": "Teste de conexão",
    "tags": ["teste"]
  }' | jq
```

### Verificar parsing JSON

Se o node está falhando ao parsear JSON:

```bash
# Testar manualmente
echo '{"test": "value"}' | node -e "
  const d = JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));
  console.log(d.test);
"
```

Deve retornar: `value`

### Ver últimos erros do sistema

```bash
# macOS
log show --predicate 'process == "bash"' --last 1h | grep carbon-brain

# Linux
journalctl -u bash --since "1 hour ago" | grep carbon-brain
```

---

## 📋 Checklist de Diagnóstico

Use este checklist quando algo não funcionar:

- [ ] Dependências instaladas? (`curl`, `node`, `bash ≥4.0`)
- [ ] Claude Code instalado? (`~/.claude/` existe)
- [ ] Hooks copiados? (`ls ~/.claude/hooks/carbon-brain-*.sh`)
- [ ] Hooks têm permissão de execução? (`ls -la`)
- [ ] Hooks registrados no settings.json? (`cat ~/.claude/settings.json`)
- [ ] Config existe? (`~/.carbon-brain/config`)
- [ ] Vault do Obsidian acessível? (`ls $OBSIDIAN_VAULT`)
- [ ] Projeto tem contexto? (`ls $OBSIDIAN_VAULT/_claude-brain/projects/`)
- [ ] Inkdrop API Server ativo? (`curl localhost:19840`)
- [ ] Credenciais corretas? (testar curl com auth)

---

## 🆘 Ainda não funcionou?

### Reinstalação limpa

```bash
cd /caminho/do/carbon-claude-brain

# Desinstalar completamente
./uninstall.sh
# Responder "s" para remover configurações

# Reinstalar do zero
./install.sh
```

### Verificar compatibilidade

```bash
# Versão do bash
bash --version
# Precisa ≥ 4.0

# Sistema operacional
uname -a
# Suportado: macOS, Linux (Ubuntu, Debian, CentOS)
# Não suportado: Windows nativo (use WSL)

# Claude Code versão
claude --version
```

### Coletar logs para suporte

Se precisar pedir ajuda, colete estas informações:

```bash
# Criar arquivo de diagnóstico
cat > ~/carbon-brain-diagnostics.txt <<EOF
# Sistema
$(uname -a)

# Bash version
$(bash --version | head -1)

# Dependências
curl: $(command -v curl && curl --version | head -1)
node: $(command -v node && node --version)

# Estrutura de arquivos
$(ls -la ~/.claude/hooks/ | grep carbon-brain)
$(ls -la ~/.claude/skills/ | grep -E "brain|obsidian|inkdrop")

# Config (SEM credenciais)
$(cat ~/.carbon-brain/config | sed 's/INKDROP_PASS=.*/INKDROP_PASS=<hidden>/')

# Settings.json (apenas hooks)
$(cat ~/.claude/settings.json | grep -A 5 carbon-brain)

# Últimos erros do log (se existir)
$(tail -20 ~/.carbon-brain/debug.log 2>/dev/null || echo "Nenhum debug.log encontrado")
EOF

cat ~/carbon-brain-diagnostics.txt
```

Poste este arquivo ao abrir uma issue no GitHub.

---

## 📚 Recursos Adicionais

- **README principal:** [README.md](../README.md)
- **Setup do Obsidian:** [setup-obsidian.md](setup-obsidian.md)
- **Setup do Inkdrop:** [setup-inkdrop.md](setup-inkdrop.md)
- **Issues no GitHub:** [github.com/marcoscarbonera/carbon-claude-brain/issues](https://github.com/marcoscarbonera/carbon-claude-brain/issues)
