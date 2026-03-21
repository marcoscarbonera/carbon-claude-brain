# Configuração de Branch Protection

Este documento descreve as configurações de proteção da branch `main` que devem ser aplicadas no GitHub.

## Por que proteger a branch main?

- Previne commits diretos que pulam revisão
- Garante que todo código passa por CI/CD
- Força code review antes de merge
- Mantém histórico limpo e rastreável
- Reduz riscos de quebrar o projeto

## Configurações Recomendadas

### Como Configurar

1. Acesse o repositório no GitHub
2. Vá em **Settings** → **Branches**
3. Em **Branch protection rules**, clique em **Add rule**
4. Em **Branch name pattern**, digite: `main`

### Regras Obrigatórias

#### ✅ Require a pull request before merging
- **Marque esta opção**
- **Required approvals**: `1` (mínimo)
- **Dismiss stale pull request approvals when new commits are pushed**: ✅ marcado
- **Require review from Code Owners**: ✅ marcado

**Por quê?** Todo código precisa de pelo menos 1 revisão antes de entrar na `main`.

#### ✅ Require status checks to pass before merging
- **Marque esta opção**
- **Require branches to be up to date before merging**: ✅ marcado

**Status checks obrigatórios** (adicione conforme aparecem no CI):
- `shellcheck`
- `security-check`
- `validate-structure`
- `test-install-dry-run (ubuntu-latest)`
- `test-install-dry-run (macos-latest)`
- `all-checks-passed`

**Por quê?** Garante que todos os testes passam antes do merge.

#### ✅ Require conversation resolution before merging
- **Marque esta opção**

**Por quê?** Força resolução de comentários de review.

#### ✅ Require linear history
- **Marque esta opção**

**Por quê?** Mantém histórico limpo (sem merge commits desnecessários).

#### ✅ Do not allow bypassing the above settings
- **Marque esta opção**

**Por quê?** Nem administradores podem pular as regras.

### Regras Opcionais (mas Recomendadas)

#### 🔹 Require signed commits
- **Marque esta opção** se quiser garantir autenticidade

**Como configurar commits assinados:**
```bash
# Gerar chave GPG
gpg --full-generate-key

# Listar chaves
gpg --list-secret-keys --keyid-format=long

# Configurar git
git config --global user.signingkey SUA_CHAVE_GPG
git config --global commit.gpgsign true
```

#### 🔹 Include administrators
- **Marque esta opção** para aplicar regras a todos

**Por quê?** Nem você, como admin, deve pular as regras.

#### 🔹 Restrict who can push to matching branches
- Se quiser limitar pushes apenas para mantenedores específicos

### Regras que NÃO devem ser ativadas

#### ❌ Allow force pushes
- **NÃO marque** - force push na main é perigoso

#### ❌ Allow deletions
- **NÃO marque** - ninguém deve deletar a main

## Resumo Visual

```
Settings → Branches → Add rule → main

[✅] Require a pull request before merging
     ├─ [✅] Required approvals: 1
     ├─ [✅] Dismiss stale approvals
     └─ [✅] Require review from Code Owners

[✅] Require status checks to pass before merging
     ├─ [✅] Require branches to be up to date
     └─ Status checks:
         ├─ shellcheck
         ├─ security-check
         ├─ validate-structure
         ├─ test-install-dry-run (ubuntu-latest)
         ├─ test-install-dry-run (macos-latest)
         └─ all-checks-passed

[✅] Require conversation resolution before merging
[✅] Require linear history
[✅] Do not allow bypassing the above settings

[🔹] Require signed commits (opcional)
[🔹] Include administrators (recomendado)

[❌] Allow force pushes (NÃO)
[❌] Allow deletions (NÃO)
```

## Testando a Proteção

Depois de configurar, tente fazer push direto para a main:

```bash
git checkout main
echo "teste" >> README.md
git add README.md
git commit -m "teste: push direto"
git push origin main
```

Você deve receber um erro:
```
remote: error: GH006: Protected branch update failed for refs/heads/main.
remote: error: Changes must be made through a pull request.
```

Isso significa que a proteção está funcionando! 🎉

## Workflow Correto

```bash
# 1. Criar branch
git checkout -b feature/minha-feature

# 2. Fazer mudanças
git add .
git commit -m "feat: adiciona nova feature"

# 3. Push para branch
git push origin feature/minha-feature

# 4. Abrir PR no GitHub

# 5. Aguardar review + CI passar

# 6. Merge via GitHub UI
```

## Para Mantenedores

Como revisor/mantenedor, você deve:

1. **Ler o código completo** - não aprove sem entender
2. **Verificar segurança** - credenciais? comandos inseguros?
3. **Testar localmente** se possível
4. **Verificar se CI passou** - todos os checks verdes
5. **Resolver comentários** antes de aprovar
6. **Fazer merge via "Squash and merge"** ou "Rebase and merge"

### Comandos Úteis

```bash
# Revisar PR localmente
gh pr checkout 123
./install.sh  # testar instalação
bash -n hooks/*.sh  # validar sintaxe

# Aprovar PR
gh pr review 123 --approve

# Merge PR
gh pr merge 123 --squash
```

## Troubleshooting

### "Status check not found"

Se um status check não aparece na lista:
1. Faça um PR de teste primeiro
2. Aguarde o CI rodar
3. Os checks aparecerão automaticamente
4. Volte e adicione-os às regras

### "Cannot merge due to missing reviews"

Certifique-se de que:
- Pelo menos 1 pessoa aprovou o PR
- O aprovador não é o autor do PR
- As aprovações não foram invalidadas por novos commits

### "Checks have failed"

Todos os status checks precisam estar verdes:
- Clique nos detalhes do check que falhou
- Corrija o problema
- Faça novo commit
- CI rodará automaticamente

## Segurança Adicional

### Proteger outras branches importantes

Se tiver branches como `develop` ou `staging`, aplique regras similares.

### Revogar tokens antigos

```bash
# Listar tokens do GitHub
gh auth status

# Revogar token
gh auth logout
```

### Audit log

Monitore mudanças suspeitas:
- Settings → Security → Audit log

## Referências

- [GitHub Branch Protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [Required Status Checks](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/about-status-checks)
- [CODEOWNERS](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)
