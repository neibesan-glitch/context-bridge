# Context Bridge

Protocole de memoire partagee et de continuite entre agents IA. Initialise la structure de documentation dans un projet pour que chaque agent (Claude Code, Cursor, Codex, Copilot, Windsurf) reprenne exactement la ou le precedent s'est arrete.

## Trigger

Use when the user says "context-bridge", "init context bridge", "initialise la memoire projet", "ajoute le protocole de handoff", "installe context bridge", or wants to set up cross-agent continuity on a project.

## What this skill does

1. Creates the `docs/` knowledge base structure in the current project
2. Generates agent directive files (CLAUDE.md, CODEX.md, .cursorrules, .github/copilot.md)
3. Sets up the handoff protocol (state, roadmap, session log, error log)
4. Everything is Markdown-based, Git-versioned, Obsidian-compatible

## Instructions

When invoked, perform these steps:

### Step 1: Check existing structure

Look for existing `docs/` folder or `CLAUDE.md` at the project root. If they exist, ask the user if they want to merge or replace.

### Step 2: Create the documentation structure

Create the following files:

```
docs/
├── INDEX.md            # Navigation hub with wiki-links
├── CODE_MAP.md         # Project architecture map (analyze current project to pre-fill)
├── state.md            # Current project state (5-line summary)
├── roadmap.md          # Goals and tasks
├── permanent/
│   ├── choix_techniques.md   # Architecture Decision Records
│   └── regles_projet.md      # Project conventions and rules
└── journal/
    ├── journal_bord.md       # Session history
    └── journal_erreurs.md    # Bug memory (immunity journal)
```

### Step 3: Generate agent directives

Create at the project root:
- `CLAUDE.md` — for Claude Code (append to existing if present)
- `CODEX.md` — for OpenAI Codex
- `.cursorrules` — for Cursor / Windsurf
- `.github/copilot.md` — for GitHub Copilot

Each file contains the same handoff protocol:
- **Start**: Read state.md, roadmap.md, journal_bord.md, journal_erreurs.md, CODE_MAP.md
- **During**: Update CODE_MAP on new modules, log decisions in choix_techniques.md
- **End**: Update state.md, add session entry to journal_bord.md, update roadmap.md

### Step 4: Pre-fill CODE_MAP

Analyze the current project structure and pre-fill `docs/CODE_MAP.md` with the actual folder tree and module descriptions.

### Step 5: Update .gitignore

Append Obsidian cache exclusions if not already present:
```
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.obsidian/plugins/*/data.json
.obsidian/graph.json
```

### Step 6: Confirm

Report what was created and remind the user:
- The protocol is now active for all supported agents
- They can open `docs/` in Obsidian for visual navigation
- The first agent to work on the project should fill in state.md and roadmap.md
