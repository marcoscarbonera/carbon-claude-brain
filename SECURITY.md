# Política de Segurança

## Versões Suportadas

Atualmente, damos suporte de segurança para as seguintes versões:

| Versão | Suporte          |
| ------ | ---------------- |
| main   | :white_check_mark: |
| < 1.0  | :x:              |

Recomendamos sempre usar a versão mais recente da branch `main`.

## Reportando uma Vulnerabilidade

Se você descobrir uma vulnerabilidade de segurança, **NÃO** abra uma issue pública.

### Processo de Reporte

1. **Envie um e-mail privado** ou abra uma [Security Advisory](https://github.com/marcoscarbonera/carbon-claude-brain/security/advisories/new) no GitHub
2. **Inclua detalhes**:
   - Descrição da vulnerabilidade
   - Passos para reproduzir
   - Impacto potencial
   - Sugestões de correção (se tiver)

3. **Aguarde resposta** em até 48 horas

### O que esperamos de você

- Dê tempo razoável para corrigirmos antes de divulgar publicamente
- Não explore a vulnerabilidade além do necessário para demonstrá-la
- Não acesse ou modifique dados de outros usuários

### O que você pode esperar de nós

- Confirmação de recebimento em até 48 horas
- Atualização sobre o progresso da correção
- Crédito público pelo reporte (se desejar)
- Correção e release o mais rápido possível

## Áreas de Atenção

Este projeto lida com informações sensíveis. Tenha atenção especial a:

### 1. Credenciais

- **Inkdrop**: usuário e senha armazenados em `~/.carbon-brain/config`
- **Obsidian**: caminho do vault pode conter informações do sistema
- Nunca commite o arquivo `~/.carbon-brain/config`
- Nunca logue credenciais em plain text

### 2. Injeção de Comandos

Os hooks executam shell scripts. Valide:
- Entradas do usuário antes de passar para `bash`
- Caminhos de arquivos (evite path traversal)
- Variáveis de ambiente

### 3. Exposição de Dados

- Notas do Obsidian podem conter informações confidenciais
- Journal do Inkdrop pode conter segredos acidentalmente
- Garanta que logs não exponham dados sensíveis

### 4. Permissões de Arquivo

- `~/.carbon-brain/config` deve ter permissão `600` (somente owner)
- Scripts de hooks devem ser executáveis apenas pelo owner
- Não use `chmod 777` em momento algum

## Práticas Recomendadas para Contribuidores

1. **Nunca commite credenciais**
   - Use `.gitignore` adequadamente
   - Revise commits antes de push
   - Use `git-secrets` ou similar

2. **Valide inputs**
   ```bash
   # Ruim
   vault_path="$1"
   cd "$vault_path"

   # Bom
   vault_path="$1"
   if [ ! -d "$vault_path" ]; then
     echo "Vault inválido"
     exit 1
   fi
   cd "$vault_path"
   ```

3. **Evite eval e execução dinâmica**
   ```bash
   # Ruim
   eval "$user_input"

   # Bom
   case "$user_input" in
     option1) do_option1 ;;
     option2) do_option2 ;;
     *) echo "Opção inválida" ;;
   esac
   ```

4. **Use aspas em variáveis**
   ```bash
   # Ruim
   cp $source $dest

   # Bom
   cp "$source" "$dest"
   ```

## Escopo de Segurança

### Está no escopo

- Exposição de credenciais
- Injeção de comandos
- Path traversal
- Exposição de dados sensíveis
- Permissões inadequadas de arquivos

### Não está no escopo

- Bugs que não afetam segurança
- Questões de usabilidade
- Vulnerabilidades em dependências externas (Obsidian, Inkdrop, Claude Code)
- Ataques que requerem acesso físico à máquina

## Atualizações de Segurança

Quando uma vulnerabilidade é corrigida:
1. Lançamos um patch imediatamente
2. Atualizamos este documento
3. Notificamos usuários via GitHub Security Advisories
4. Creditamos o pesquisador (se permitido)

## Checklist de Segurança para PRs

Antes de aprovar um PR, verifique:
- [ ] Não expõe credenciais
- [ ] Valida inputs do usuário
- [ ] Não usa `eval` ou execução dinâmica insegura
- [ ] Usa aspas em variáveis shell
- [ ] Não cria arquivos com permissões inseguras
- [ ] Não loga informações sensíveis
- [ ] Segue princípio do menor privilégio

## Contato

Para questões de segurança urgentes, abra uma Security Advisory no GitHub:
https://github.com/marcoscarbonera/carbon-claude-brain/security/advisories/new

## Agradecimentos

Agradecemos aos pesquisadores de segurança que reportam vulnerabilidades de forma responsável.
