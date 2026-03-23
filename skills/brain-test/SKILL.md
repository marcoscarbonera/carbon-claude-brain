---
name: brain-test
description: >
  Executa diagnóstico completo do carbon-claude-brain.
  Verifica hooks, skills, Obsidian vault e Inkdrop API.
---

# /brain-test — Diagnóstico do Sistema

Executa verificação completa da instalação do carbon-claude-brain.

## O que verifica

1. ✅ **Hooks instalados** - carbon-brain-start.sh, end.sh, post-tool.sh
2. ✅ **Skills instaladas** - brain, obsidian, inkdrop
3. ✅ **Obsidian vault** - acessibilidade e estrutura _claude-brain
4. ✅ **Inkdrop API** - conectividade com servidor local
5. ✅ **settings.json** - registro correto dos hooks

## Como executar

```bash
#!/usr/bin/env bash
source ~/.claude/hooks/lib-carbon-brain.sh
load_config

echo "🧠 carbon-claude-brain — Diagnóstico"
echo "======================================"
echo ""

# 1. Verificar hooks
echo "🔍 Verificando hooks..."
HOOKS_OK=true
for hook in carbon-brain-start.sh carbon-brain-end.sh carbon-brain-post-tool.sh lib-carbon-brain.sh; do
  HOOK_PATH="$HOME/.claude/hooks/$hook"
  if [ -f "$HOOK_PATH" ]; then
    if [ -x "$HOOK_PATH" ] || [[ "$hook" == "lib-carbon-brain.sh" ]]; then
      echo "  ✅ $hook"
    else
      echo "  ⚠️  $hook existe mas não tem permissão de execução"
      HOOKS_OK=false
    fi
  else
    echo "  ❌ $hook não encontrado"
    HOOKS_OK=false
  fi
done
echo ""

# 2. Verificar skills
echo "🔍 Verificando skills..."
SKILLS_OK=true
for skill in brain obsidian inkdrop brain-test brain-save brain-search brain-context brain-plan; do
  SKILL_PATH="$HOME/.claude/skills/$skill/SKILL.md"
  if [ -f "$SKILL_PATH" ]; then
    echo "  ✅ $skill/SKILL.md"
  else
    echo "  ⚠️  $skill/SKILL.md não encontrado"
    SKILLS_OK=false
  fi
done
echo ""

# 3. Verificar Obsidian vault
echo "🔍 Verificando Obsidian vault..."
if [ -z "$OBSIDIAN_VAULT" ]; then
  echo "  ❌ OBSIDIAN_VAULT não configurado"
else
  if [ -d "$OBSIDIAN_VAULT" ]; then
    echo "  ✅ Vault acessível: $OBSIDIAN_VAULT"

    if [ -d "$OBSIDIAN_VAULT/_claude-brain" ]; then
      echo "  ✅ Estrutura _claude-brain existe"

      if [ -d "$OBSIDIAN_VAULT/_claude-brain/global" ]; then
        echo "  ✅ _claude-brain/global existe"
      fi
      if [ -d "$OBSIDIAN_VAULT/_claude-brain/projects" ]; then
        echo "  ✅ _claude-brain/projects existe"
      fi
    else
      echo "  ⚠️  Estrutura _claude-brain não existe (será criada na primeira sessão)"
    fi
  else
    echo "  ❌ Vault não encontrado: $OBSIDIAN_VAULT"
  fi
fi
echo ""

# 4. Verificar Inkdrop API
echo "🔍 Verificando Inkdrop API..."
if [ -z "$INKDROP_URL" ]; then
  echo "  ℹ️  Inkdrop não configurado (opcional)"
else
  RESPONSE=$(curl -s --max-time 3 -u "$INKDROP_USER:$INKDROP_PASS" "$INKDROP_URL/notes?limit=1" 2>&1)
  CURL_EXIT=$?

  if [ $CURL_EXIT -eq 0 ] && echo "$RESPONSE" | grep -q '"items"'; then
    echo "  ✅ Inkdrop API respondendo em $INKDROP_URL"

    NOTE_COUNT=$(echo "$RESPONSE" | node -e "
      try {
        const d = JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));
        console.log(d.count || 0);
      } catch(e) { console.log('?'); }
    " 2>/dev/null)
    echo "  ℹ️  Total de notas: $NOTE_COUNT"
  else
    echo "  ⚠️  Falha ao conectar com Inkdrop"
    echo "     URL: $INKDROP_URL"
    echo "     Verifique se o servidor local está ativo"
  fi
fi
echo ""

# 5. Verificar settings.json
echo "🔍 Verificando settings.json..."
SETTINGS="$HOME/.claude/settings.json"
if [ -f "$SETTINGS" ]; then
  if grep -q "carbon-brain" "$SETTINGS" 2>/dev/null; then
    echo "  ✅ Hooks registrados no settings.json"
  else
    echo "  ⚠️  Hooks podem não estar registrados"
  fi
else
  echo "  ⚠️  settings.json não encontrado"
fi
echo ""

# Resumo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$HOOKS_OK" = true ] && [ "$SKILLS_OK" = true ] && [ -d "$OBSIDIAN_VAULT" ]; then
  echo "✅ Setup OK! carbon-claude-brain está pronto."
else
  echo "⚠️  Alguns problemas encontrados. Veja acima."
  echo "   Tente reinstalar: ./uninstall.sh && ./install.sh"
fi
echo ""
```

## Quando usar

- Após instalação inicial com `./install.sh`
- Quando houver problemas de carregamento de contexto
- Para verificar se Inkdrop está acessível
- Antes de reportar bugs
