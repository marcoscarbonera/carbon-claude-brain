# Skills Guide

Complete reference for all carbon-claude-brain skills.

## Available Skills

### `/carbon-brain-save`

**Purpose:** Save the current session summary when ending a session.

**What it does:**
- Updates Obsidian with decisions made during the session
- Creates a journal note in Inkdrop with session summary
- Captures learnings and important insights

**When to use:**
- At the end of a coding session
- Before switching to another project
- After completing a significant milestone

**Example:**
```bash
/carbon-brain-save
```

Claude will summarize what was done and save it to both Obsidian and Inkdrop.

---

### `/carbon-brain-context`

**Purpose:** Show the current context loaded from Obsidian for the project.

**What it does:**
- Displays the project plan from Obsidian
- Shows architecture notes
- Lists recent decisions
- Displays current project status

**When to use:**
- To verify what context Claude has loaded
- To review the current project state
- To check if the right information is available

**Example:**
```bash
/carbon-brain-context
```

---

### `/carbon-brain-plan`

**Purpose:** Create or update the project plan in Obsidian.

**What it does:**
- Creates a structured plan for the current project
- Updates existing plan with new information
- Organizes tasks and decisions
- Saves to `_claude-brain/{project-name}/plan.md`

**When to use:**
- Starting a new project
- Major feature planning
- Updating project direction
- After architecture decisions

**Example:**
```bash
/carbon-brain-plan
```

Claude will guide you through creating or updating the plan.

---

### `/carbon-brain-test`

**Purpose:** Verify that carbon-claude-brain is configured correctly.

**What it does:**
- ✅ Checks if hooks are installed
- ✅ Checks if skills are installed
- ✅ Verifies Obsidian vault is accessible
- ✅ Tests Inkdrop API connection
- ✅ Validates `settings.json` registration
- ✅ Shows diagnostic information

**When to use:**
- After installation
- Troubleshooting issues
- Verifying configuration changes
- Before starting a new project

**Example:**
```bash
/carbon-brain-test
```

**What to expect:**
```
✅ Hooks installed correctly
✅ Skills registered
✅ Obsidian vault found: /Users/you/Documents/vault
✅ Inkdrop server responding
✅ Configuration valid

carbon-claude-brain is ready to use!
```

---

### `/carbon-brain-search`

**Purpose:** Search for a term across **all projects** in your Obsidian vault.

**What it does:**
- Searches all project notes in `_claude-brain/`
- Finds past solutions and decisions
- Shows context from specific projects
- Helps avoid reinventing the wheel

**When to use:**
- Looking for how you solved a similar problem before
- Finding past decisions on a topic
- Discovering patterns across projects

**Example:**
```bash
/carbon-brain-search "authentication"
/carbon-brain-search "rate limiting"
/carbon-brain-search "database migration"
```

**Output:**
```
Found in project-a:
  - Implemented JWT authentication with refresh tokens
  - Used bcrypt for password hashing

Found in project-b:
  - OAuth2 integration with Google
  - Session-based auth for admin panel
```

---

### `/carbon-brain-search-patterns`

**Purpose:** Search general learnings and patterns in **Inkdrop** (not project-specific).

**What it does:**
- Searches notes tagged with `#claude-aprendizado`
- Finds reusable patterns (`#claude-pattern`)
- Retrieves personal preferences (`#claude-preferencia`)
- Shows resolved errors (`#claude-erro-resolvido`)

**When to use:**
- Looking for general programming patterns
- Finding personal coding preferences
- Retrieving past learnings
- Looking up how you solved a common error

**Example:**
```bash
/carbon-brain-search-patterns "error handling"
/carbon-brain-search-patterns "#react hooks"
/carbon-brain-search-patterns "typescript generics"
```

**Output:**
```
Pattern: Error Handling
  - Always use custom error classes
  - Log errors with context
  - Never swallow errors silently

Learning: React Hooks
  - Use useCallback for event handlers
  - Memoize expensive calculations with useMemo
  - Keep useEffect dependencies minimal
```

---

## Personal Preferences System

Configure conventions and patterns that Claude should follow in **every project**.

### Setup

1. Create notes in Inkdrop with tag `#claude-preferencia`
2. Claude automatically loads them in every session
3. Syncs via Inkdrop Cloud between machines

### Examples

**Code Style Preferences:**
```markdown
Title: Code Style Guide
Tags: #claude-preferencia

- TypeScript strict mode always
- Single quotes in JS/TS
- 2 spaces indentation
- No semicolons in TS/JS
- Prefer async/await over .then()
```

**Commit Preferences:**
```markdown
Title: Git Conventions
Tags: #claude-preferencia

- Commits must follow Conventional Commits
- Format: type(scope): description
- Types: feat, fix, docs, style, refactor, test, chore
```

**Testing Preferences:**
```markdown
Title: Testing Standards
Tags: #claude-preferencia

- Always add tests for new features
- Use Jest for unit tests
- Use Testing Library for React components
- Minimum 80% code coverage
```

### Best Practices

**✅ Good (concise):**
```markdown
- TypeScript strict mode always
- Single quotes in JS/TS
- 2 spaces indentation
```

**❌ Bad (wastes tokens):**
```markdown
I always prefer to use TypeScript because I believe that
static typing helps catch errors early and improves code
quality. I've been using it for years and...
(500 lines of philosophy)
```

**Recommended limit:** 500-1000 lines TOTAL across all `#claude-preferencia` notes.

---

## Tags System

### Obsidian (Project-Specific)

No specific tags required. Organization is folder-based:
```
_claude-brain/
├── project-name/
│   ├── project.md        # Main project info
│   ├── plan.md           # Implementation plan
│   └── decisions.md      # Decision log
```

### Inkdrop (Personal Knowledge)

| Tag | Purpose | Example |
|-----|---------|---------|
| `#claude-preferencia` | Personal preferences that apply to all projects | Code style, commit format |
| `#claude-journal` | Session journals (auto-created) | Daily work log |
| `#claude-aprendizado` | General learnings | How to optimize React renders |
| `#claude-pattern` | Reusable patterns | Error handling pattern |
| `#claude-erro-resolvido` | Resolved errors with solutions | Fixed TypeScript generic error |

---

## Advanced Usage

### Combining Skills

**Start of day:**
```bash
/carbon-brain-context          # See what you were working on
/carbon-brain-search-patterns "react"  # Review relevant patterns
```

**During development:**
```bash
/carbon-brain-plan            # Update plan as you go
/carbon-brain-search "similar feature"  # Find past solutions
```

**End of day:**
```bash
/carbon-brain-save            # Save session summary
```

### Workflow Example

```bash
# 1. Start new feature
/carbon-brain-context
# Review: "Working on user authentication"

# 2. Check if you've done this before
/carbon-brain-search "authentication"
# Found: "Used JWT in project-x"

# 3. Check your preferences
/carbon-brain-search-patterns "auth"
# Found: "Always use bcrypt for passwords"

# 4. Update plan
/carbon-brain-plan
# Add: "Implement JWT auth with bcrypt"

# 5. End session
/carbon-brain-save
# Saved: "Completed auth setup with JWT"
```

---

## Troubleshooting Skills

### Skill not found

**Problem:** `/carbon-brain-search` returns "skill not found"

**Solution:**
1. Run `/carbon-brain-test` to verify installation
2. Check `~/.claude/skills/` for skill files
3. Restart Claude Code
4. Run `./install.sh` again if needed

### Skill runs but no results

**Problem:** Skill executes but returns empty results

**Solution:**
1. Verify Obsidian vault path: `cat ~/.carbon-brain/config`
2. Check if `_claude-brain/` folder exists in vault
3. For Inkdrop skills, test API: `curl -u "$INKDROP_USER:$INKDROP_PASS" http://localhost:19840/notes`
4. Create some test notes with the appropriate tags

### Skill is slow

**Problem:** Skills take too long to execute

**Solution:**
1. Reduce size of context files in Obsidian
2. Keep personal preferences concise (<1000 lines total)
3. Archive old projects from `_claude-brain/`
4. Use `CARBON_BRAIN_SKIP=1` for quick sessions

---

## See Also

- [Quick Reference](quick-reference.md) - All commands in one place
- [Setup Guide](setup-obsidian.md) - Detailed Obsidian configuration
- [Token Optimization](token-optimization.md) - Managing token usage
- [Troubleshooting](troubleshooting.md) - Common issues and solutions
