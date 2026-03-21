# Comparison: carbon-claude-brain vs claude-mem

## Technical Differences

| Feature | claude-mem | carbon-claude-brain |
|---------|-----------|---------------------|
| **Database** | SQLite + Chroma vector DB | Filesystem (markdown) |
| **Backend** | Node.js Worker + Server | Shell scripts + HTTP API |
| **Server** | Port 37777 | No server (uses Inkdrop local server) |
| **Language** | ~83% TypeScript | 100% shell script + markdown |
| **Installation** | `npx` command | `./install.sh` |
| **Dependencies** | Node.js, SQLite, Chroma | `bash`, `curl`, Obsidian, Inkdrop |
| **Vector Search** | ✅ Yes (Chroma) | ❌ No (simple grep) |
| **Semantic Search** | ✅ Yes | ❌ No |

## When to Use carbon-claude-brain

✅ **Use it if:**
- You already use Obsidian for notes/PKM
- You already use Inkdrop for journaling
- You prefer data in open format (markdown)
- You want full control over your data
- Small/medium projects (<50 context files)
- You value simplicity and easy debugging
- You don't want background processes running
- You want cross-machine sync for personal preferences

❌ **Don't use if:**
- You want zero-config setup
- You need semantic/vector search
- Large projects with lots of context (>100 files)
- You don't want to pay for Inkdrop (or don't want to use it)
- Team needs to share memory (without Obsidian Sync)

## When to Use claude-mem Instead

✅ **Use claude-mem if:**
- You want quick setup (`npx`)
- You need advanced vector search
- Large projects with lots of context
- You want everything self-contained (no external deps)
- Team already uses other tools (not Obsidian/Inkdrop)
- You need semantic search capabilities

## Philosophy Differences

### carbon-claude-brain Philosophy

**Minimalist Architecture:**
- Zero lock-in: your data in markdown
- Zero background services
- Zero complex dependencies
- 100% debuggable with `cat` and `bash`

**Clear Separation:**
- Obsidian = long-term structured knowledge (project-specific)
- Inkdrop = temporal session diary (personal, syncs)

**Data Ownership:**
- All data in human-readable markdown
- Easy to backup, migrate, or abandon the tool
- No vendor lock-in

### claude-mem Philosophy

**Integrated Solution:**
- All-in-one package
- Vector search for better context retrieval
- Self-contained and portable

**Advanced Features:**
- Semantic search
- Better for large codebases
- More sophisticated querying

## Migration Path

### From claude-mem to carbon-claude-brain

1. Export your claude-mem data (if possible)
2. Install carbon-claude-brain
3. Manually copy important context to Obsidian vault
4. Gradually build up your knowledge base

### From carbon-claude-brain to claude-mem

1. Your markdown files remain intact
2. Install claude-mem
3. Optionally import relevant context
4. Both can coexist if needed

## Complementary Usage

You can potentially use both:
- **claude-mem** for large, complex projects needing vector search
- **carbon-claude-brain** for personal projects where you want markdown control

Just be aware of token consumption when using both simultaneously.
