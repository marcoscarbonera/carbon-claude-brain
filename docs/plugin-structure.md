# Plugin Structure

This project is structured as a Claude Code marketplace plugin with optimized token usage.

## Directory Structure

```
carbon-claude-brain/
├── .claude-plugin/
│   └── plugin.json              # Marketplace manifest (metadata only)
├── skills/
│   ├── carbon-brain/            # Main skill (optimized: 525 words, ~700 tokens)
│   │   ├── SKILL.md            # Concise overview with quick reference
│   │   ├── examples/           # Executable bash scripts
│   │   │   ├── brain-save-example.sh
│   │   │   ├── brain-learn-example.sh
│   │   │   ├── brain-error-example.sh
│   │   │   ├── brain-search-example.sh
│   │   │   ├── brain-search-patterns-example.sh
│   │   │   └── brain-test-example.sh
│   │   └── reference/          # Detailed documentation
│   │       └── commands-reference.md
│   ├── carbon-brain-context/   # Individual skill: show loaded context
│   ├── carbon-brain-error/     # Individual skill: document errors
│   ├── carbon-brain-learn/     # Individual skill: save learnings
│   ├── carbon-brain-plan/      # Individual skill: project planning
│   ├── carbon-brain-save/      # Individual skill: save session
│   ├── carbon-brain-search/    # Individual skill: search projects
│   ├── carbon-brain-search-patterns/ # Individual skill: search patterns
│   ├── carbon-brain-setup/     # Individual skill: initial setup
│   └── carbon-brain-test/      # Individual skill: diagnostics
├── hooks/
│   ├── lib-carbon-brain.sh     # Shared library with helper functions
│   ├── session-start.sh        # Loads context at session start
│   ├── session-end.sh          # Saves summary at session end
│   ├── post-tool-use.sh        # Captures important decisions
│   └── auto-save-helper.sh     # Auto-save session summaries
├── templates/
│   └── obsidian/               # Templates for vault structure
├── lib-setup.sh                # Setup library functions
└── install.sh                  # Main installation script
```

## Token Optimization

The main `carbon-brain` skill was refactored following [superpowers:writing-skills](https://github.com/anthropics/superpowers) guidelines:

- **Before:** ~3500 words (~7000 tokens per session)
- **After:** 525 words (~700 tokens per session)
- **Savings:** 90% reduction (6300 tokens saved per session!)

### Key Optimizations

1. **Modular Structure**
   - `SKILL.md` - Concise overview (loaded every invocation)
   - `examples/` - Executable scripts (loaded on demand)
   - `reference/` - Detailed docs (loaded on demand)

2. **Markdown Relative Links**
   - Uses `[text](file.md)` for marketplace compatibility
   - Claude Code marketplace resolves these automatically

3. **Quick Reference Table**
   - Fast scanning for common commands
   - Reduces need to read full documentation

4. **Executable Examples**
   - Standalone bash scripts with proper shebang
   - Can be run directly without copy/paste

## Plugin Manifest (plugin.json)

The `.claude-plugin/plugin.json` manifest includes:

```json
{
  "name": "carbon-claude-brain",
  "version": "1.0.0",
  "description": "Persistent memory system...",
  "skills": [
    "carbon-brain",
    "carbon-brain-context",
    ...
  ],
  "hooks": {
    "PreToolUse": ["session-start.sh"],
    "PostToolUse": ["post-tool-use.sh"],
    "Stop": ["session-end.sh"],
    "SessionEnd": ["auto-save-helper.sh"]
  },
  "config": {
    "obsidian_vault": {
      "type": "string",
      "description": "Path to your Obsidian vault",
      "required": true
    },
    ...
  }
}
```

### Important Notes

- ⚠️ **IMPORTANT:** Only `plugin.json` goes inside `.claude-plugin/`
- All other directories (`skills/`, `hooks/`, `templates/`) must be at plugin root
- Skills use relative markdown links: `[text](file.md)`
- Examples are executable with proper shebang: `#!/usr/bin/env bash`

## Hook System

### Session Lifecycle Hooks

**1. PreToolUse (session-start.sh)**
- Triggers: First tool use in session
- Purpose: Load context from Obsidian + Inkdrop
- Runtime: ~200-500ms
- Token cost: ~1500-3000 tokens

**2. PostToolUse (post-tool-use.sh)**
- Triggers: After every tool use
- Purpose: Capture important decisions
- Runtime: ~50-100ms
- Token cost: 0 (uses regex matching)

**3. Stop (session-end.sh)**
- Triggers: Session end (Ctrl+C, exit)
- Purpose: Update project status
- Runtime: ~100-200ms
- Token cost: 0 (file writes only)

**4. SessionEnd (auto-save-helper.sh)**
- Triggers: Session end (after Stop)
- Purpose: Generate intelligent summary
- Runtime: ~5-10s
- Token cost: ~2000-8000 tokens
- Uses: Claude Haiku agent

## Helper Functions (lib-carbon-brain.sh)

### Configuration Management

**load_config()** - Load environment from `.env` or legacy `config`
```bash
source ~/.claude/hooks/lib-carbon-brain.sh
load_config  # Exports OBSIDIAN_VAULT, INKDROP_URL, etc.
```

Auto-migrates legacy `config` → `.env` format if needed.

### Obsidian Functions

**save_to_obsidian_journal()** - Save session to daily journal
```bash
save_to_obsidian_journal "$PROJECT_NAME" "$DATE" "$START_TIME" "$END_TIME" "$CONTENT"
```

**save_learning()** - Add to global learnings.md
```bash
save_learning "Performance" "Always add indexes on JOIN columns"
```

**save_error_solved()** - Document error resolution
```bash
save_error_solved "$DATE" "Title" "Context" "Error msg" "Solution" "Prevention"
```

### Inkdrop Functions

**save_to_inkdrop_journal()** - Save to Inkdrop (if enabled)
```bash
if is_inkdrop_enabled; then
  save_to_inkdrop_journal "$PROJECT_NAME" "$DATE" "$START_TIME" "$END_TIME" "$CONTENT"
fi
```

**is_inkdrop_enabled()** - Check if Inkdrop is configured
```bash
if is_inkdrop_enabled; then
  echo "Inkdrop is enabled"
fi
```

## Setup Functions (lib-setup.sh)

### Obsidian Detection

**detect_obsidian_vaults()** - Auto-detect vaults from system
```bash
source ./lib-setup.sh
detect_obsidian_vaults  # Returns: /path/to/vault|OPEN or /path/to/vault|
```

Parses `~/Library/Application Support/obsidian/obsidian.json` and ranks by:
1. Open status
2. Timestamp
3. Alphabetical

**select_obsidian_vault()** - Visual UI for vault selection
```bash
select_obsidian_vault  # Interactive menu with numbered options
# Auto-selects if only 1 vault found (with confirmation)
# Exports OBSIDIAN_VAULT variable
```

### Inkdrop Setup

**setup_inkdrop_wizard()** - Interactive 4-step setup
```bash
setup_inkdrop_wizard
# Step 1: Detect if Inkdrop running (localhost:19840)
# Step 2: Get credentials
# Step 3: Test connection (3 retries)
# Step 4: List/select notebook
# Exports INKDROP_URL, INKDROP_USER, INKDROP_PASS, INKDROP_NOTEBOOK_ID
```

### Validation

**validate_configuration()** - Pre-flight checks
```bash
validate_configuration "$OBSIDIAN_VAULT" "$INKDROP_URL" "$INKDROP_USER" "$INKDROP_PASS"
```

Checks:
- Vault exists + writable
- Disk space >1MB
- `~/.claude` writable
- `settings.json` valid JSON
- Inkdrop connection (if configured)

## Error Handling Patterns

### Silent Failures for Optional Features

Hooks use silent failures for optional components (like Inkdrop):

```bash
RESPONSE=$(curl -s --max-time 5 ... 2>&1)
CURL_EXIT=$?

if [ $CURL_EXIT -ne 0 ]; then
  log_error "component: failure reason"
  # Continue without failing - Inkdrop is optional
fi
```

### JSON Parsing

Uses Node.js for JSON processing (Claude Code has Node):

```bash
echo "$JSON_RESPONSE" | node -e "
  try {
    const data = JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8'));
    console.log(data.items[0].title);
  } catch (e) {
    process.exit(1);
  }
" 2>&1
```

## File Conventions

### Templates

Located in `templates/{obsidian,inkdrop}/`:
- Copied to user's vault during installation
- Provide structure for notes
- Include frontmatter with tags

### Hook Naming

Installed hooks are prefixed to avoid conflicts:
- `session-start.sh` → `~/.claude/hooks/carbon-brain-start.sh`
- `session-end.sh` → `~/.claude/hooks/carbon-brain-end.sh`
- `post-tool-use.sh` → `~/.claude/hooks/carbon-brain-post-tool.sh`
- `auto-save-helper.sh` → (registered in settings.json SessionEnd hook)

### Configuration Files

Priority order:
1. `~/.carbon-brain/.env` (preferred, standard format)
2. `~/.carbon-brain/config` (legacy, bash source format)

Both use `600` permissions for security.

## Local Testing

Test as local plugin before publishing:

```bash
# Test with local directory
claude --plugin-dir ./carbon-claude-brain

# Or symlink to plugins directory
ln -s $(pwd) ~/.claude/plugins/carbon-claude-brain
```

## Publishing to Marketplace

### Structure Requirements

- Only `plugin.json` goes inside `.claude-plugin/`
- All other files at plugin root
- Skills use relative markdown links
- Examples are executable with proper shebang

### Marketplace Commands

```bash
# Add marketplace
/plugin marketplace add marcoscarbonera/carbon-claude-brain

# Install plugin
/plugin install carbon-claude-brain@carbon-claude-brain

# Update plugin
/plugin update carbon-claude-brain

# Remove plugin
/plugin remove carbon-claude-brain
```

## Development Workflow

1. **Make Changes**
   - Edit skills, hooks, or templates
   - Test locally with `--plugin-dir`

2. **Test Installation**
   ```bash
   ./install.sh --dry-run
   ./install.sh
   /carbon-brain-test
   ```

3. **Commit & Push**
   ```bash
   git add .
   git commit -m "feat: add feature"
   git push origin main
   ```

4. **Create Release**
   ```bash
   gh release create v1.0.0 --notes "Release notes..."
   ```

5. **Users Update**
   ```bash
   /plugin update carbon-claude-brain
   ```

---

**Related Documentation:**
- [Contributing Guide](../CONTRIBUTING.md)
- [Token Optimization](token-optimization.md)
- [Security Best Practices](security-best-practices.md)
