# 🧠 carbon-claude-brain

> Persistent memory for Claude Code using Obsidian as a second brain and Inkdrop as a journal — no databases, no services, no complexity.

[🇧🇷 Versão em Português](README_pt-BR.md)

## How It Works

### Session Lifecycle

```mermaid
flowchart TB
    Start([Start Session]) --> Hook1[session-start.sh]
    Hook1 --> Obs1[📖 Load from Obsidian]
    Hook1 --> Ink1[📓 Load from Inkdrop]

    Obs1 --> |Project Context|Load[Context Loaded]
    Ink1 --> |Personal Preferences|Load
    Ink1 --> |Previous Learnings|Load

    Load --> Work[👨‍💻 Coding Session]

    Work --> Skills{Skills Available}
    Skills --> |/brain-plan|PlanSkill[Update Plan]
    Skills --> |/brain-context|CtxSkill[View Context]
    Skills --> |/brain-search|SearchSkill[Search Projects]
    Skills --> |/brain-search-patterns|PatternSkill[Search Patterns]

    PlanSkill --> SaveObs[💾 Save to Obsidian]

    Work --> Hook2[post-tool-use.sh]
    Hook2 --> |Important Decisions|Capture[Capture Notes]

    Work --> End([End Session])
    End --> Hook3[session-end.sh]
    Hook3 --> SaveObs2[💾 Update Obsidian Status]
    Hook3 --> SaveInk[📓 Save Journal to Inkdrop]

    style Start fill:#fff,stroke:#000,stroke-width:3px
    style End fill:#fff,stroke:#000,stroke-width:3px
    style Work fill:#fff,stroke:#000,stroke-width:2px
    style Load fill:#fff,stroke:#000,stroke-width:2px
    style Skills fill:#fff,stroke:#000,stroke-width:2px
```

### Architecture Overview

```mermaid
graph LR
    Claude[🤖 Claude Code]
    Project[📁 Your Project]

    Obsidian[📖 Obsidian<br/>Project Knowledge<br/><small>plans, decisions, architecture</small>]
    Inkdrop[📓 Inkdrop<br/>Personal Memory<br/><small>preferences, learnings, patterns</small>]

    Claude -->|works on| Project

    Claude -->|reads at start| Obsidian
    Claude -->|reads at start| Inkdrop

    Claude -->|saves at end| Obsidian
    Claude -->|saves at end| Inkdrop

    style Claude fill:#fff,stroke:#000,stroke-width:3px
    style Project fill:#fff,stroke:#000,stroke-width:2px
    style Obsidian fill:#fff,stroke:#000,stroke-width:2px
    style Inkdrop fill:#fff,stroke:#000,stroke-width:2px
```

**Business Logic:**
1. **Session Start** — Claude automatically loads context from Obsidian (this project) and Inkdrop (your preferences)
2. **Work** — Claude codes on your project with full context
3. **Session End** — Claude automatically saves decisions to Obsidian and learnings to Inkdrop

## Prerequisites

- [Claude Code](https://claude.ai/claude-code) installed
- [Obsidian](https://obsidian.md) with local vault configured
- [Inkdrop](https://www.inkdrop.app) with local server active (`localhost:19840`)
- `bash` ≥4.0, `curl`, `node` (usually pre-installed)

## Installation

```bash
git clone https://github.com/marcoscarbonera/carbon-claude-brain
cd carbon-claude-brain
./install.sh
```

The script will ask for:
- Path to your Obsidian vault
- Credentials for Inkdrop local server

### ⚠️ Security Note

Inkdrop credentials are stored at `~/.carbon-brain/.env` (standard `.env` format with `600` permissions). This is acceptable because:
- The Inkdrop server is **local** (`localhost:19840`)
- Not exposed to the internet
- Only you have access to your machine
- Standard `.env` format (compatible with Docker, etc.)

**Recommendations:**
- ✅ Use a different password from your Inkdrop Cloud account
- ✅ Keep the local server disabled when not in use
- ❌ **NEVER** version control or share `~/.carbon-brain/.env`
- 🔒 `.env` is already in `.gitignore` by default

**To completely uninstall:**
```bash
./uninstall.sh
```

## What It Does

### Obsidian — Project Knowledge (Local)
- Implementation plans and architecture
- Technical decision logs
- Living project documentation

### Inkdrop — Personal Knowledge (Syncs)
- Personal preferences (applies to all projects)
- Session journals
- General learnings and patterns
- Resolved errors

## Available Skills

| Skill | Purpose |
|-------|---------|
| `/brain-test` | Verify installation |
| `/brain-context` | View loaded context |
| `/brain-plan` | Create/update project plan |
| `/brain-save` | Save session summary |
| `/brain-search` | Search all projects |
| `/brain-search-patterns` | Search personal knowledge |

**[→ Complete Skills Documentation](docs/skills-guide.md)**

---

## Token Usage

Context injection costs ~1500-3000 tokens per session.

| Session Type | Worth It? |
|-------------|-----------|
| Quick (1-3 msgs) | ❌ Not recommended |
| Medium (5-10 msgs) | ⚖️ Break even |
| Long (15+ msgs) | ✅ Saves tokens overall |

**Temporarily disable:**
```bash
CARBON_BRAIN_SKIP=1 claude
```

**[→ Token Optimization Guide](docs/token-optimization.md)**

---

## Documentation

### 📚 Setup & Configuration
- [Obsidian Setup](docs/setup-obsidian.md)
- [Inkdrop Setup](docs/setup-inkdrop.md)
- [Personal Preferences](docs/setup-personal-preferences.md)
- [Security Best Practices](docs/security-best-practices.md)

### 🎯 Usage Guides
- [Skills Reference](docs/skills-guide.md)
- [Quick Reference Card](docs/quick-reference.md)
- [Token Optimization](docs/token-optimization.md)
- [Troubleshooting](docs/troubleshooting.md)

### 🔍 Comparisons & Decisions
- [vs claude-mem](docs/comparison.md) - Which one to use?

---

## Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md).

**Security:** [SECURITY.md](SECURITY.md) | **Branch Protection:** [docs/branch-protection.md](docs/branch-protection.md)

---

## Uninstall

```bash
./uninstall.sh
```

## License

MIT

---

**Made with ❤️ for developers who value simplicity and data ownership**
