# Setup — Inkdrop

## Pré-requisitos

- Inkdrop instalado e com conta ativa (versão 5.x ou superior)
- Servidor local HTTP embutido no Inkdrop

## Ativar o servidor local

O Inkdrop já vem com servidor HTTP local embutido. Para ativá-lo:

1. Abra o Inkdrop
2. Vá em **Preferências → Local HTTP Server** (ou Preferences → Local HTTP Server)
3. **Ative o servidor** clicando no toggle
4. Configure as credenciais locais:
   - **Username:** escolha um usuário (ex: `carbon`, `local`, `seu-nome`)
   - **Password:** escolha uma senha forte (diferente da sua conta Inkdrop Cloud)
   - **Port:** `19840` (padrão, não mude)
   - **Bind Address:** `127.0.0.1` (localhost, não mude)
5. Clique em **Start Server** ou reinicie o Inkdrop
6. O servidor estará em `http://localhost:19840`

## Testar a API

```bash
# Configure suas credenciais
export INKDROP_USER="seu_usuario"
export INKDROP_PASS="sua_senha"

# Teste a API
curl -u "$INKDROP_USER:$INKDROP_PASS" http://localhost:19840/notes?limit=1
```

Se retornar JSON, está funcionando.

## Configuração no carbon-claude-brain

Durante o `install.sh`, informe:
- URL: `http://localhost:19840`
- Usuário e senha configurados no plugin
- **Notebook ID** (opcional): ID do notebook onde criar as notas

As credenciais ficam salvas em `~/.carbon-brain/.env` (permissão 600).

### Configurar Notebook de Destino (Opcional)

Por padrão, as notas são criadas na inbox do Inkdrop. Para organizá-las em um notebook específico:

1. **Criar notebook no Inkdrop** (ex: "Claude Brain")
2. **Descobrir o ID do notebook:**
   ```bash
   claude
   /carbon-brain-setup
   ```
3. **Copiar o ID** (formato: `book:abc123def456`)
4. **Adicionar ao `.env`:**
   ```bash
   nano ~/.carbon-brain/.env
   ```
   Adicione a linha:
   ```
   INKDROP_NOTEBOOK_ID="book:abc123def456"
   ```
5. **Reiniciar Claude Code** - próximas notas serão criadas nesse notebook

**Nota:** O notebook pode ser um sub-notebook (ex: `Personal > Claude Brain`). Basta usar o ID dele.

## Por que o Inkdrop?

- **Sincroniza online** — journal disponível em qualquer máquina
- **API simples** — só `curl`, sem dependências
- **Interface amigável** — você consegue ler/editar as notas normalmente
- **Multiplataforma** — macOS, Linux, Windows, iOS, Android

## Organização: Notebooks vs Tags

O carbon-claude-brain suporta **duas formas** de organizar as notas:

### Opção 1: Apenas Tags (Padrão)
As notas ficam na **inbox** do Inkdrop, organizadas por tags:
- `#claude-preferencia` - Preferências pessoais de código
- `#claude-journal` - Journals de sessões
- Nome do projeto (ex: `#carbon-claude-brain`)

**Vantagens:**
- ✅ Zero configuração
- ✅ Simples de começar

**Desvantagens:**
- ❌ Inbox fica poluída com o tempo

### Opção 2: Notebook Específico + Tags (Recomendado)
As notas são criadas em um **notebook dedicado** + tags:

1. **Criar notebook no Inkdrop:**
   - No Inkdrop, clique em **+ Add Notebook**
   - Nome: `Claude Brain` (ou qualquer nome)
   - Pode ser sub-notebook (ex: `Personal > Claude Brain`)

2. **Configurar o ID do notebook:**
   ```bash
   claude
   /carbon-brain-setup  # Lista todos os notebooks e seus IDs
   ```
   Copie o ID (ex: `book:abc123`) e adicione ao `.env`:
   ```bash
   nano ~/.carbon-brain/.env
   ```
   Adicione:
   ```
   INKDROP_NOTEBOOK_ID="book:abc123"
   ```

3. **Resultado:**
   - Todas as notas vão para `Claude Brain/`
   - Ainda mantém as tags (`#claude-journal`, `#claude-preferencia`)
   - Inbox limpa!

**Vantagens:**
- ✅ Organização hierárquica
- ✅ Inbox limpa
- ✅ Pode ter sub-notebooks por projeto
- ✅ Combina com tags para busca

### Tags Geradas Automaticamente
Independente da opção escolhida, as seguintes tags são sempre adicionadas:
- `#claude-preferencia` - Notas de preferências pessoais
- `#claude-journal` - Journals de sessões
- `#nome-do-projeto` - Nome do projeto (ex: `#carbon-claude-brain`)

## Troubleshooting

### Servidor não inicia
1. Verifique se não há outro processo usando porta 19840:
   ```bash
   lsof -i :19840
   # ou
   netstat -an | grep 19840
   ```
2. Se houver, mate o processo ou mude a porta no Inkdrop
3. Reinicie o Inkdrop completamente

### Erro de autenticação
```bash
# Verifique se as credenciais estão corretas
curl -v -u "$INKDROP_USER:$INKDROP_PASS" http://localhost:19840/
```

Se retornar `401 Unauthorized`:
- Verifique se digitou usuário/senha corretamente
- Certifique-se que o servidor está ativo (veja Logs)
- Reconfigure as credenciais no Inkdrop

### Ver logs do servidor
No Inkdrop:
1. Preferências → Local HTTP Server
2. Clique em **View Server Logs**
3. Logs mostram todas as requisições e erros

### Testar conexão completa
```bash
# Listar notebooks
curl -u "$INKDROP_USER:$INKDROP_PASS" http://localhost:19840/books

# Criar uma nota de teste
curl -X POST \
  -u "$INKDROP_USER:$INKDROP_PASS" \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","body":"Testing API"}' \
  http://localhost:19840/notes
```

## Referências Oficiais

- [Local HTTP Server - Inkdrop Docs](https://developers.inkdrop.app/data-access/local-http-server)
- [Integration Guide](https://developers.inkdrop.app/guides/integrate-with-external-programs)
- [Inkdrop API Documentation](https://developers.inkdrop.app/)
- [MCP Server Integration](https://docs.inkdrop.app/reference/mcp-server)
