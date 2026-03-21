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
curl -u SEU_USUARIO:SUA_SENHA http://localhost:19840/notes?limit=1
```

Se retornar JSON, está funcionando.

## Configuração no carbon-claude-brain

Durante o `install.sh`, informe:
- URL: `http://localhost:19840`
- Usuário e senha configurados no plugin

As credenciais ficam salvas em `~/.carbon-brain/config` (permissão 600).

## Por que o Inkdrop?

- **Sincroniza online** — journal disponível em qualquer máquina
- **API simples** — só `curl`, sem dependências
- **Interface amigável** — você consegue ler/editar as notas normalmente
- **Multiplataforma** — macOS, Linux, Windows, iOS, Android

## Notebooks e Tags Sugeridos

### Criar Notebook
Crie um notebook chamado `claude-brain` no Inkdrop para organizar as notas geradas:
1. No Inkdrop, clique em **+ Add Notebook**
2. Nome: `claude-brain`
3. Este notebook será usado para armazenar journals de sessões

### Criar Tags
Crie as seguintes tags para organizar melhor:
- `#claude-preferencia` - Para suas preferências pessoais de código
- `#claude-journal` - Para journals de sessões
- `#claude-learning` - Para aprendizados e decisões importantes

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
curl -v -u SEU_USUARIO:SUA_SENHA http://localhost:19840/
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
curl -u USUARIO:SENHA http://localhost:19840/books

# Criar uma nota de teste
curl -X POST \
  -u USUARIO:SENHA \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","body":"Testing API"}' \
  http://localhost:19840/notes
```

## Referências Oficiais

- [Local HTTP Server - Inkdrop Docs](https://developers.inkdrop.app/data-access/local-http-server)
- [Integration Guide](https://developers.inkdrop.app/guides/integrate-with-external-programs)
- [Inkdrop API Documentation](https://developers.inkdrop.app/)
- [MCP Server Integration](https://docs.inkdrop.app/reference/mcp-server)
