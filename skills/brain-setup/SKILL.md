---
name: brain-setup
description: >
  Wizard de configuração do carbon-claude-brain.
  Configure Obsidian vault e Inkdrop após instalação via marketplace.
---

# /brain-setup — Configurar carbon-claude-brain

Este comando executa o wizard de configuração interativo para o carbon-claude-brain.

## Quando usar

- Após instalar o plugin via marketplace pela primeira vez
- Quando quiser reconfigurar o Obsidian vault
- Para adicionar ou modificar configuração do Inkdrop
- Se moveu seu vault do Obsidian para outro local

## O que o wizard faz

1. **Detecta modo de instalação** (marketplace vs manual)
2. **Configura Obsidian vault** (obrigatório)
   - Solicita caminho do vault
   - Valida que o diretório existe
   - Tenta detectar automaticamente
3. **Configura Inkdrop** (opcional)
   - URL da API local
   - Credenciais
   - Notebook de destino
   - Testa conexão
4. **Salva configuração**
   - Cria arquivo `.env` em `${CLAUDE_PLUGIN_DATA}` (marketplace) ou `~/.carbon-brain` (manual)
   - Define permissões seguras (600)
5. **Cria estrutura no Obsidian**
   - Diretórios: `_claude-brain/global/`, `_claude-brain/projects/`
   - Arquivos base: `learnings.md`, `errors-solved.md`, `patterns.md`

## Modos de execução

### Modo 1: Não-interativo (Recomendado)

**Vantagens:** Reprodutível, sem prompts, ideal para automação

1. Copie `.env.example` para `.env` na raiz do plugin:
   ```bash
   cp ${CLAUDE_PLUGIN_ROOT}/.env.example ${CLAUDE_PLUGIN_ROOT}/.env
   ```

2. Edite o `.env` e preencha os valores:
   ```bash
   # Exemplo: Apenas Obsidian
   OBSIDIAN_VAULT="/Users/seu-usuario/Documents/MyVault"
   INKDROP_URL=""
   INKDROP_USER=""
   INKDROP_PASS=""
   INKDROP_NOTEBOOK_ID=""
   ```

3. Execute o configure.sh:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/configure.sh
   ```

O script detectará o `.env` e executará sem perguntas.

### Modo 2: Interativo

Execute sem criar o `.env`:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/configure.sh
```

O wizard perguntará cada configuração.

## Exemplo de uso (skill)

```bash
#!/usr/bin/env bash

# Detectar se é instalação marketplace ou manual
if [ -n "$CLAUDE_PLUGIN_ROOT" ]; then
  SCRIPT_PATH="$CLAUDE_PLUGIN_ROOT/configure.sh"
else
  SCRIPT_PATH="./configure.sh"
fi

# Executar wizard
if [ -f "$SCRIPT_PATH" ]; then
  bash "$SCRIPT_PATH"
else
  echo "❌ Erro: configure.sh não encontrado"
  echo "   Esperado em: $SCRIPT_PATH"
  exit 1
fi
```

## Após a configuração

Teste a instalação:

```bash
/brain-test
```

Veja o contexto carregado:

```bash
/brain-context
```

## Reconfiguração

Você pode executar o wizard quantas vezes quiser. Ele sobrescreverá o arquivo `.env` existente com as novas configurações.

## Troubleshooting

**Erro: "Diretório não encontrado"**
- Verifique o caminho do vault do Obsidian
- Use caminho absoluto (ex: `/Users/seu-usuario/Documents/Obsidian`)
- Não use `~` ou variáveis de ambiente

**Erro: "Falha ao conectar com Inkdrop"**
- Verifique se o Inkdrop está aberto
- Confirme que o plugin `local-rest-api` está instalado e ativo
- Teste manualmente: `curl -u user:pass http://localhost:19840/notes?limit=1`

**Permissões negadas ao criar diretórios**
- Verifique permissões no vault do Obsidian
- Execute: `chmod -R u+w "$OBSIDIAN_VAULT/_claude-brain"`

## Localização da configuração

**Modo marketplace:**
- Configuração: `${CLAUDE_PLUGIN_DATA}/.env`
- Persiste entre updates do plugin

**Modo manual:**
- Configuração: `~/.carbon-brain/.env`
- Compatível com versões antigas

## Segurança

- O arquivo `.env` tem permissões `600` (somente o usuário pode ler/escrever)
- Credenciais do Inkdrop são locais (não sincronizam com cloud)
- Use senha diferente da sua conta Inkdrop cloud
