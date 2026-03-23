# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

carbon-claude-brain is a persistent memory system for Claude Code that uses:
- **Obsidian** (local markdown vault) for project-specific knowledge
- **Inkdrop** (local REST API) for personal preferences and session journals

The system injects context at session start and saves learnings at session end via Claude Code hooks.

## Architecture

### Hook System (Session Lifecycle)

```
session-start.sh → load context → Claude works → post-tool-use.sh → session-end.sh → save learnings
```

**Key files:**
- `hooks/lib-carbon-brain.sh` - Shared library with helper functions
- `hooks/session-start.sh` - Loads context from Obsidian + Inkdrop (including global knowledge)
- `hooks/session-end.sh` - Saves session summary to both systems
- `hooks/post-tool-use.sh` - Captures important decisions during session

**What gets loaded at session start:**
1. Inkdrop preferences (`#claude-preferencia` tag)
2. **Global knowledge** (learnings.md, errors-solved.md, patterns.md)
3. Project context (project-context.md)
4. Recent decisions (decision-log.md, last 20 lines)
5. Last session journal (from Inkdrop)

**Environment variables:**
- `CARBON_BRAIN_SKIP=1` - Bypass context loading (for quick sessions)
- `INKDROP_NOTEBOOK_ID` - Notebook ID where notes are created (optional)
- Config loaded from `~/.carbon-brain/.env` or `~/.carbon-brain/config` (legacy)

### Skills (User-Invocable Commands)

Located in `skills/{brain,obsidian,inkdrop}/SKILL.md`:
- `/brain-test` - Diagnostic tool
- `/brain-context` - Show loaded context
- `/brain-plan` - Create/update project plan
- `/brain-save` - Save session summary
- `/brain-search` - Search across all Obsidian projects
- `/brain-search-patterns` - Search Inkdrop personal knowledge
- `/brain-inkdrop-setup` - List Inkdrop notebooks and configure notebook ID

### Obsidian Structure

```
$OBSIDIAN_VAULT/
└── _claude-brain/
    ├── projects/{project-name}/
    │   ├── project-context.md    # Main project context
    │   ├── decision-log.md       # Technical decisions
    │   └── architecture.md       # Architecture docs
    └── global/
        ├── journals/             # Daily session journals
        ├── learnings.md          # Reusable learnings
        ├── errors-solved.md      # Documented error solutions
        └── patterns.md           # Code patterns
```

### Inkdrop Integration

HTTP API at `localhost:19840` (if enabled):
- Stores personal preferences with tag `#claude-preferencia`
- Stores session journals with tag `#claude-journal`
- Supports organizing notes in specific notebooks (via `INKDROP_NOTEBOOK_ID`)
- Optional - system works with Obsidian only if not configured

**Notebook Configuration:**
- Use `/brain-inkdrop-setup` to list available notebooks and get IDs
- Add `INKDROP_NOTEBOOK_ID="book:xxx"` to `~/.carbon-brain/.env`
- Notes will be created in that notebook + tags
- If not configured, notes go to Inkdrop inbox

## Development Commands

### Installation

```bash
./install.sh
```

Installs hooks, skills, and creates template structure. Prompts for:
- Obsidian vault path
- Inkdrop credentials (optional)

### Uninstallation

```bash
./uninstall.sh
```

### Testing

```bash
# Test full system
/brain-test

# Test with skip mode (bypass context loading)
CARBON_BRAIN_SKIP=1 claude
```

### Linting

Markdown linting via `.markdownlint.json` (enforced in CI):
```bash
# CI runs markdownlint on all .md files
```

## Code Patterns

### Helper Functions (lib-carbon-brain.sh)

**load_config()** - Load environment from `.env` or legacy `config`
```bash
source ~/.claude/hooks/lib-carbon-brain.sh
load_config  # Exports OBSIDIAN_VAULT, INKDROP_URL, etc.
```

**save_to_obsidian_journal()** - Save session to daily journal
```bash
save_to_obsidian_journal "$PROJECT_NAME" "$DATE" "$START_TIME" "$END_TIME" "$CONTENT"
```

**save_to_inkdrop_journal()** - Save to Inkdrop (if enabled)
```bash
if is_inkdrop_enabled; then
  save_to_inkdrop_journal "$PROJECT_NAME" "$DATE" "$START_TIME" "$END_TIME" "$CONTENT"
fi
```

**save_learning()** - Add to global learnings.md
```bash
save_learning "Performance" "Always add indexes on JOIN columns"
```

**save_error_solved()** - Document error resolution
```bash
save_error_solved "$DATE" "Title" "Context" "Error msg" "Solution" "Prevention"
```

### Error Handling Pattern

Hooks use silent failures for optional features:
```bash
RESPONSE=$(curl -s --max-time 5 ... 2>&1)
CURL_EXIT=$?

if [ $CURL_EXIT -ne 0 ]; then
  log_error "component: failure reason"
  # Continue without failing - Inkdrop is optional
fi
```

### JSON Parsing Pattern

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

### Hooks Naming

Installed hooks are prefixed to avoid conflicts:
- `session-start.sh` → `~/.claude/hooks/carbon-brain-start.sh`
- `session-end.sh` → `~/.claude/hooks/carbon-brain-end.sh`
- `post-tool-use.sh` → `~/.claude/hooks/carbon-brain-post-tool.sh`

### Configuration Files

Priority order:
1. `~/.carbon-brain/.env` (preferred, standard format)
2. `~/.carbon-brain/config` (legacy, bash source format)

Both use `600` permissions for security.

## Security Considerations

- Inkdrop credentials are **local-only** (`localhost:19840`)
- Never commit `~/.carbon-brain/.env` (in `.gitignore`)
- Use different password than Inkdrop Cloud account
- Hooks log errors to `~/.carbon-brain/errors.log` (redact sensitive data)
- Branch protection enabled on `main` (requires PR + review)

## Token Optimization

Context injection costs ~1500-3000 tokens per session:
- Keep notes concise (use bullet points, not paragraphs)
- Preferences should be max 500-1000 lines total
- Decision logs: 3-5 lines per decision
- Journals: 200-300 words per session

Disable for quick sessions:
```bash
CARBON_BRAIN_SKIP=1 claude
```

## Contributing

Follow Conventional Commits:
- `feat:` new functionality
- `fix:` bug fixes
- `docs:` documentation only
- `refactor:` code refactoring
- `chore:` build/config updates

All changes require:
- PR to `main` (no direct push)
- At least 1 reviewer approval
- CI checks passing
- Updated documentation if needed

See [CONTRIBUTING.md](CONTRIBUTING.md) for full guidelines.

## Common Workflows

### Adding a New Hook

1. Create script in `hooks/`
2. Add to `install.sh` (copy + chmod)
3. Register in `settings.json` via Node.js injection
4. Test with `/brain-test`

### Adding a New Skill

1. Create `skills/{name}/SKILL.md`
2. Add to `install.sh` (copy step)
3. Document in `docs/skills-guide.md`
4. Test invocation

### Modifying Context Structure

1. Update template in `templates/obsidian/`
2. Update `session-start.sh` loading logic
3. Document in README.md architecture section
4. Consider migration path for existing users
