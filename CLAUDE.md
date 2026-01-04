# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Claude Code plugin** for integrating with Lovable.dev projects. It's distributed as a plugin, not a typical software project with build steps or test suites.

- **Repository**: https://github.com/10K-Digital/lovable-claude-code
- **Current Version**: 1.4.1
- **Type**: Claude Code plugin (no compilation, no dependencies, no build process)
- **Distribution**: Via Claude Code plugin marketplace (10K-Digital/lovable-claude-code)

## Architecture

### Plugin Structure

This plugin follows Claude Code's plugin architecture with three core components:

```
.claude-plugin/          # Plugin metadata
├── plugin.json          # Main plugin definition (version, description)
└── marketplace.json     # Marketplace listing configuration

commands/                # Slash commands (/lovable:* commands)
├── init-lovable.md      # Initialize project context (most complex command)
├── deploy-edge.md       # Deploy edge functions
├── apply-migration.md   # Apply database migrations
├── sync-lovable.md      # Sync with Lovable Cloud
├── yolo.md             # Toggle automation mode
└── [others].md

skills/                  # Contextual skills (auto-activate based on conditions)
├── lovable/
│   ├── SKILL.md        # Core Lovable integration patterns
│   └── references/     # Supporting documentation
│       ├── CLAUDE-template.md  # Template for generated CLAUDE.md files
│       ├── prompts.md          # Lovable prompt library
│       └── secret-detection.md # Secret scanning patterns
└── yolo/
    ├── SKILL.md        # Browser automation orchestration
    └── references/     # Automation workflows
        ├── automation-workflows.md  # Browser automation steps
        ├── detection-logic.md       # When to trigger automation
        ├── post-push-automation.md  # Auto-deploy after git push
        ├── secrets-extraction.md    # Extract secrets from Lovable UI
        └── testing-procedures.md    # Deployment verification tests

agents/                  # (Currently empty, reserved for future)

.claude/                 # Plugin-level settings
└── settings.local.json  # Pre-approved git operations
```

### Key Architectural Concepts

#### 1. Two-Tier Documentation System

**Commands** (`/lovable:*`) contain:
- User-facing instructions for Claude to execute
- Step-by-step procedural workflows
- User interaction patterns (questions, confirmations)
- CLAUDE.md generation logic

**Skills** (auto-activate) contain:
- Conceptual knowledge about Lovable integration
- When to use what approach
- Reference materials for complex operations
- Browser automation workflows

**Reference files** (`skills/*/references/`) contain:
- Detailed implementation procedures
- Edge case handling
- UI automation selectors and wait conditions
- Testing procedures

#### 2. CLAUDE.md Generation Pattern

This plugin's core feature is **generating CLAUDE.md files** for user projects (not this repo). The flow:

1. User runs `/lovable:init` in their Lovable project
2. Plugin scans their codebase (edge functions, migrations, secrets)
3. Asks 11-13 questions about their setup
4. Generates `CLAUDE.md` in their project root using `skills/lovable/references/CLAUDE-template.md`
5. This CLAUDE.md gives future Claude instances context about their Lovable project

**Critical distinction**: This repo contains the plugin code. User projects get a generated CLAUDE.md.

#### 3. Auto-Push and Yolo Mode (Auto-Deploy) Features

**Auto-Push** (v1.4.0, refined in v1.4.1):
- After completing a task successfully, automatically commit and push to GitHub
- **Independent feature** - can be enabled without yolo mode
- Configured via `Auto-Push to GitHub: on/off` in user's CLAUDE.md (separate section)
- Implemented in `skills/lovable/SKILL.md` (lines 154-227)
- Safety checks: task success, file changes, on main branch

**Yolo Mode / Auto-Deploy** (v1.3.0):
- After git push, automatically deploy backend changes to Lovable via browser automation
- **Requires auto-push to be enabled** (dependency enforced)
- Configured via yolo mode section in user's CLAUDE.md
- Implemented in `skills/yolo/` with browser automation
- Detects changes in `supabase/functions/` or `supabase/migrations/`

**Independence vs Dependency**:
- Auto-push can be ON with yolo mode OFF (manual deployment workflow)
- Yolo mode REQUIRES auto-push to be ON (automatic deployment)
- Disabling yolo mode does NOT disable auto-push

**Workflow when both enabled**:
```
User asks for changes
  → Claude makes changes
  → Auto-push: commit + push to GitHub
  → Yolo mode: detect backend changes → navigate to Lovable → submit deployment
  → Verification tests run
  → Done (zero manual commands)
```

**Workflow with only auto-push** (yolo mode off):
```
User asks for changes
  → Claude makes changes
  → Auto-push: commit + push to GitHub
  → GitHub syncs frontend to Lovable instantly
  → User manually deploys backend via /deploy-edge or copy-paste prompts
```

#### 4. Yolo Mode (Browser Automation)

"Yolo mode" = browser automation for Lovable deployments. Requires Claude in Chrome extension.

**Activation conditions** (in user projects):
- `yolo_mode: on` in user's CLAUDE.md
- Commands: `/deploy-edge`, `/apply-migration`
- Auto-triggers after git push if `auto_deploy: on`

**Implementation**:
- Orchestration logic: `skills/yolo/SKILL.md`
- Browser workflows: `skills/yolo/references/automation-workflows.md`
- Detection logic: `skills/yolo/references/detection-logic.md`
- Testing: `skills/yolo/references/testing-procedures.md`

**Graceful degradation**: Always provides manual prompts as fallback if automation fails.

## Working with This Repository

### Versioning

When making changes that affect functionality:

1. Update version in `.claude-plugin/plugin.json`
2. Add entry to `CHANGELOG.md` following existing format
3. Update `README.md` if user-facing features changed
4. Update `.claude-plugin/marketplace.json` if needed (usually auto-synced)

**Version scheme**: Semantic versioning
- Patch (1.4.x): Bug fixes, documentation
- Minor (1.x.0): New features, new commands
- Major (x.0.0): Breaking changes to commands/skills

### Making Changes

#### Adding/Modifying Commands

Commands are markdown files in `commands/`. Structure:

```markdown
---
description: Short description for command listing
---

# Command Name

Full user-facing instructions that Claude will read and execute.

## Instructions

Step-by-step procedural logic...
```

**Important**: Commands describe what Claude should DO, not what the feature is.

#### Adding/Modifying Skills

Skills are markdown files in `skills/*/SKILL.md`. Structure:

```markdown
---
name: skill-name
description: |
  When this skill activates (conditions).
  What it provides (knowledge, patterns).
---

# Skill Name

Conceptual knowledge, patterns, and guidance...
```

**Important**: Skills describe WHEN to activate and WHAT to know, not step-by-step procedures (those go in references/).

#### Reference Files

Reference files (`skills/*/references/*.md`) contain:
- Detailed procedures that skills reference
- Browser automation selectors and workflows
- Edge case handling
- Testing procedures
- Templates (like CLAUDE-template.md)

### Auto-Push Configuration in This Repo

This repository has `.claude/settings.local.json` with pre-approved git operations:

```json
{
  "permissions": {
    "allow": [
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git push:*)",
      "Bash(git pull:*)",
      "Bash(git rebase:*)"
    ]
  }
}
```

This allows Claude to commit and push changes when helping develop this plugin.

## Important Patterns

### 1. User Project vs Plugin Repo Context

Always distinguish between:
- **This repo**: The plugin source code (what you're working on now)
- **User projects**: Lovable projects where this plugin is used

Most documentation in this repo describes how to work with **user projects**, not this repo itself.

### 2. Lovable Integration Model

Lovable uses **two-way GitHub sync** on main branch only:
- ✅ Frontend (`src/`) syncs automatically
- ⚠️ Backend (edge functions, migrations) require Lovable prompts to deploy
- ❌ Database operations (tables, RLS, storage) must be done directly in Lovable UI

This plugin bridges the gap by:
1. Detecting when backend operations are needed
2. Generating exact Lovable prompts
3. Optionally automating prompt submission via browser

### 3. Question Flow in /init-lovable

The initialization command asks 11-13 questions in specific order:
1. Backend type (Lovable Cloud vs own Supabase)
2. Production URL
3. GitHub repository
4. Supabase project (if own)
5. Lovable project URL (optional, enables automation)
6. Secret detection method
7. Edge functions context
8. Database tables (optional)
9. **Auto-push toggle** ← NEW in v1.4.0, independent feature
10. Special instructions
11. Yolo mode toggle (checks auto-push requirement)
12. Testing configuration (if yolo enabled)
13. Lovable URL (if skipped in Q5 but yolo enabled)

**Order matters**: Auto-push (Q9) asked before yolo mode (Q11) because yolo requires it.

### 4. Safety and Fallbacks

**Golden rule**: Never block the user. Every automation must have manual fallback.

Examples:
- Browser automation fails → Show manual prompt to copy-paste
- Auto-push fails → Suggest manual git commands
- Auto-deploy fails → Show deployment prompt for manual execution

### 5. Beta Features

Yolo mode (browser automation) is marked as **beta**:
- Always show beta warnings when enabling
- Explain risks and requirements
- Provide manual alternatives
- Gracefully handle UI changes

## Common Workflows

### Publishing a New Version

1. Make your changes to commands/skills/references
2. Update `.claude-plugin/plugin.json` version
3. Update `CHANGELOG.md` with changes
4. Update `README.md` if needed
5. Commit with message: "Bump version to X.Y.Z"
6. Push to GitHub
7. Plugin marketplace auto-updates from GitHub

### Testing Changes Locally

This plugin has no automated tests. To test:

1. Make changes to plugin files
2. Use the plugin in a test Lovable project
3. Run commands like `/lovable:init` to verify behavior
4. Check generated CLAUDE.md files
5. Test automation features if modified

### Adding a New Command

1. Create `commands/new-command.md`
2. Add frontmatter with description
3. Write step-by-step instructions for Claude
4. Reference relevant skills if needed
5. Update README.md to mention new command
6. Update version and CHANGELOG.md

### Adding Reference Documentation

1. Create file in appropriate `skills/*/references/` directory
2. Write detailed procedures, workflows, or templates
3. Reference from skill's SKILL.md using relative path
4. Keep references focused on implementation details

## Plugin Distribution

- **Installation**: `/plugin marketplace add 10K-Digital/lovable-claude-code`
- **Namespace**: `lovable` (commands are `/lovable:*`)
- **Auto-updates**: Users can enable in Claude Code settings
- **Marketplace**: https://github.com/10K-Digital/lovable-claude-code

## Key Files to Understand

If you need to understand how this plugin works:

1. **README.md** - User-facing documentation and feature explanations
2. **CHANGELOG.md** - Version history and changes
3. **commands/init-lovable.md** - Most complex command, orchestrates project setup
4. **skills/lovable/SKILL.md** - Core integration patterns and auto-push logic
5. **skills/yolo/SKILL.md** - Browser automation orchestration
6. **skills/lovable/references/CLAUDE-template.md** - Template for generated project files
7. **skills/yolo/references/automation-workflows.md** - Browser automation implementation




Each version builds on previous automation layers to reduce manual work.

### v1.4.1 Architecture Change

Originally in v1.4.0, auto-push was tied to yolo mode. In v1.4.1, this was changed to:
- Auto-push is now a separate, independent feature
- Users can enable auto-push without yolo mode (faster git workflow, manual deploys)
- Yolo mode still requires auto-push (one-way dependency)
- Clearer separation in CLAUDE.md template and `/yolo` command
