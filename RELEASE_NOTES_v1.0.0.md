# v1.0.0 - Intelligent Setup & Auto-Save

> 🎉 **First official marketplace release** - Persistent memory system for Claude Code using Obsidian + Inkdrop

## ✨ Key Features

### 🤖 Auto-Save Sessions
- **Intelligent summaries** generated automatically when you close Claude Code
- Uses Claude Haiku agent (fast & lightweight)
- Saves to Obsidian journals + Inkdrop (if enabled)
- ~5-10s at session end, ~2-8k tokens/session
- [→ Auto-Save Documentation](https://github.com/marcoscarbonera/carbon-claude-brain/blob/main/docs/auto-save.md)

### 🧠 Global Knowledge System
Automatically loads cross-project knowledge in every session:
- **learnings.md** - Reusable learnings and best practices
- **errors-solved.md** - Documented error solutions
- **patterns.md** - Code patterns and snippets
- ~1500-3000 tokens per session

### 📦 Intelligent Installation
- 🔍 **Auto-detects Obsidian vaults** from `obsidian.json`
- 📂 **Visual vault selection** with open vaults highlighted
- 🧪 **Interactive Inkdrop wizard** (4 steps: detect → credentials → test → notebook)
- ✅ **Pre-flight validation** (vault access, disk space, Claude Code setup)
- 🔄 **Smart upgrades** with config preservation and auto-migration

**Simplified setup:** 4 manual prompts → 1-2 prompts (80%+ auto-detection)

### ⚡ Token Optimization
- Main skill: ~7000 tokens → ~700 tokens (**90% reduction**)
- Modular structure: `SKILL.md` + `examples/` + `reference/`
- Context injection: ~1500-3000 tokens per session
- Total overhead: ~3500-11000 tokens/session (context + auto-save)

## 📦 Installation

### From Marketplace (Recommended)

```bash
# Add marketplace
/plugin marketplace add marcoscarbonera/carbon-claude-brain

# Install plugin
/plugin install carbon-claude-brain@carbon-claude-brain

# Run interactive setup wizard
/carbon-brain-setup
```

**Setup wizard includes:**
- Obsidian vault selection (auto-detected)
- Optional Inkdrop configuration
- Notebook organization (optional)
- Validation before installation

### Manual Installation

```bash
git clone https://github.com/marcoscarbonera/carbon-claude-brain
cd carbon-claude-brain
./install.sh
```

**Dry-run mode** (test without changes):
```bash
./install.sh --dry-run
```

## 🔧 What's Included

**12 User-Invocable Skills:**
- `/carbon-brain-setup` - Configuration wizard
- `/carbon-brain-test` - System diagnostics
- `/carbon-brain-context` - View loaded context
- `/carbon-brain-plan` - Project planning
- `/carbon-brain-save` - Manual session save
- `/carbon-brain-search` - Search all projects
- `/carbon-brain-search-patterns` - Search personal knowledge
- `/carbon-brain-learn` - Save reusable learning
- `/carbon-brain-error` - Document solved error
- `/carbon-brain-obsidian` - Obsidian operations
- `/carbon-brain-inkdrop` - Inkdrop operations

**4 Lifecycle Hooks:**
- `PreToolUse` (session-start.sh) - Loads context at session start
- `PostToolUse` (post-tool-use.sh) - Captures important decisions during session
- `Stop` (session-end.sh) - Updates project status at session end
- `SessionEnd` (auto-save-helper.sh) - **Generates intelligent summary (NEW!)**

**Context Loaded Each Session:**
- ⚙️ Personal preferences (Inkdrop)
- 📚 Global learnings (cross-project knowledge)
- 🐛 Previously solved errors
- 🎯 Reusable code patterns
- 📁 Current project context
- 🏛️ Recent technical decisions (last 20 lines)
- 📔 Last session journal

## 🔄 Upgrades & Migration

**If upgrading from pre-v1.0:**
- Legacy `config` file → `.env` format (auto-migrated)
- Existing configuration preserved
- No manual intervention required

**To upgrade:**
```bash
/plugin update carbon-claude-brain
```

## ⚙️ Requirements

- [Claude Code](https://claude.ai/claude-code) installed
- [Obsidian](https://obsidian.md) with local vault
- [Inkdrop](https://www.inkdrop.app) with local server (`localhost:19840`) - **optional**
- `bash` ≥4.0, `curl`, `node` ≥14.0

## 📚 Documentation

### Getting Started
- [README](https://github.com/marcoscarbonera/carbon-claude-brain#readme) - Quick overview
- [Quick Reference](https://github.com/marcoscarbonera/carbon-claude-brain/blob/main/docs/quick-reference.md) - Cheat sheet

### Setup Guides
- [Obsidian Setup](https://github.com/marcoscarbonera/carbon-claude-brain/blob/main/docs/setup-obsidian.md)
- [Inkdrop Setup](https://github.com/marcoscarbonera/carbon-claude-brain/blob/main/docs/setup-inkdrop.md)
- [Personal Preferences](https://github.com/marcoscarbonera/carbon-claude-brain/blob/main/docs/setup-personal-preferences.md)

### Feature Guides
- [Auto-Save Feature](https://github.com/marcoscarbonera/carbon-claude-brain/blob/main/docs/auto-save.md) - **NEW!**
- [Skills Guide](https://github.com/marcoscarbonera/carbon-claude-brain/blob/main/docs/skills-guide.md)
- [Token Optimization](https://github.com/marcoscarbonera/carbon-claude-brain/blob/main/docs/token-optimization.md)

### Advanced
- [Comparison vs claude-mem](https://github.com/marcoscarbonera/carbon-claude-brain/blob/main/docs/comparison.md)
- [Security Best Practices](https://github.com/marcoscarbonera/carbon-claude-brain/blob/main/docs/security-best-practices.md)
- [Troubleshooting](https://github.com/marcoscarbonera/carbon-claude-brain/blob/main/docs/troubleshooting.md)

## 🙏 Acknowledgments

Built with:
- [Claude Code](https://claude.ai/claude-code) - AI-powered CLI
- [Obsidian](https://obsidian.md) - Knowledge management
- [Inkdrop](https://www.inkdrop.app) - Note-taking with sync

## 📄 License

MIT

---

**Made with ❤️ for developers who value simplicity and data ownership**
