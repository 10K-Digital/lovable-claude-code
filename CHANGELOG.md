# Changelog

All notable changes to the Lovable Claude Code plugin will be documented in this file.

## [1.6.0] - 2026-01-04

### Added

#### First Agent Implementation - Sync-Agent
- **New autonomous sync-agent** (`agents/sync-agent.md`) for multi-phase project synchronization
- Completes the plugin's architectural maturity with all four workflow types:
  - ✅ Commands (user interaction)
  - ✅ Skills (knowledge)
  - ✅ Hooks (event automation)
  - ✅ Agents (complex autonomous tasks) **← NEW**

#### Sync-Agent Capabilities
- **5-phase autonomous workflow**:
  1. Git synchronization (fetch, merge, conflict handling)
  2. Secret discovery (codebase scan, .env.example, Lovable Cloud)
  3. State comparison (identify new/removed/changed secrets)
  4. Update proposal (generate diff, preserve user customizations)
  5. Application (write CLAUDE.md if approved)
- **5 operational modes**: interactive, auto-apply, dry-run, manual, debug
- **Independent context window** - doesn't pollute main coding conversation
- **Parallel execution capable** - user can continue working while sync runs
- **Comprehensive error handling** with graceful degradation
- **Preserves all user customizations** in CLAUDE.md

#### Architectural Benefits
- ✅ **Independent context**: Sync operations run in separate 200K token budget
- ✅ **Not related to current code task**: Meta-operations isolated from development work
- ✅ **High complexity justified**: 5 phases, multiple tools, complex decision trees
- ✅ **Parallel workflows enabled**: Background sync while user continues coding
- ✅ **Reference implementation**: Establishes pattern for future agents

### Changed

#### /lovable:sync Command Refactored
- Refactored from procedural to agent-delegation architecture
- Command now focuses on UX (flag parsing, progress display)
- Complex sync logic moved to sync-agent
- **Breaking change**: None - all flags and behavior preserved
- **User experience**: Identical output, more reliable execution

**Before (procedural)**:
- 359 lines of inline logic
- Git, secret detection, comparison, updates all in command
- Difficult to test and maintain
- Clutters main conversation with sync details

**After (agent-delegation)**:
- 342 lines focused on UX and orchestration
- Invokes sync-agent for autonomous execution
- Clean separation of concerns
- Agent runs in separate context

### Fixed

#### Removed Duplication in Lovable Skill
- **Deleted** auto-push explanation section from `skills/lovable/SKILL.md` (lines 154-174)
- Auto-push is now 100% handled by `hooks/auto-push.sh` (added in v1.5.0)
- Skills no longer explain hook implementation details
- Cleaner separation between skills (knowledge) and hooks (automation)

**Why this matters**:
- Skills should provide knowledge Claude needs, not explain implementation
- Hook runs automatically regardless - no need to document internal behavior
- Reduces confusion about what Claude should do vs. what happens automatically

### Architectural Improvements

#### Complete Plugin Architecture
The plugin now demonstrates best practices for all workflow types:

**Commands** (user-invoked, interactive):
- Example: `/lovable:init`, `/lovable:sync`, `/lovable:deploy-edge`
- Use when: User needs to trigger, requires confirmations

**Skills** (contextual knowledge):
- Example: `lovable` (architecture), `yolo` (automation orchestration)
- Use when: Claude needs to understand concepts or patterns

**Hooks** (event-driven automation):
- Example: `auto-sync` (Start), `auto-push` (Stop)
- Use when: Deterministic, no user interaction, background tasks

**Agents** (complex autonomous tasks):
- Example: `sync-agent` (multi-phase synchronization)
- Use when: Independent context needed, parallel-capable, high complexity

#### Decision Guide Updated
- Added clear criteria for when to use each pattern
- Emphasized context isolation and parallel execution for agents
- Documented in plan and architectural review

### Documentation

- New file: `agents/sync-agent.md` - Comprehensive agent documentation
- Updated: `commands/sync-lovable.md` - Simplified with agent delegation
- Updated: `skills/lovable/SKILL.md` - Removed auto-push duplication
- Updated: Architectural review plan saved at `.claude/plans/`

### Benefits of This Release

**For Users**:
- ✅ No breaking changes - all existing workflows work identically
- ✅ More reliable /lovable:sync execution (agent-based)
- ✅ Cleaner skill documentation (no implementation details)
- ✅ Foundation for future autonomous features

**For Developers**:
- ✅ Clear architectural patterns for all workflow types
- ✅ Reference implementation for future agents
- ✅ Better separation of concerns
- ✅ Easier to test and maintain

**For the Plugin Ecosystem**:
- ✅ Demonstrates agent pattern in production
- ✅ Shows value of context isolation
- ✅ Enables parallel execution capabilities
- ✅ Completes architectural maturity

### Technical Details

**Agent Invocation Pattern**:
```
Command parses flags
   ↓
Configure agent mode
   ↓
Invoke sync-agent
   ↓
Agent executes autonomously (5 phases)
   ↓
Display progress (pass-through)
   ↓
Show results
```

**Files Modified**:
- `.claude-plugin/plugin.json` - Version bump to 1.6.0
- `skills/lovable/SKILL.md` - Removed lines 154-174 (auto-push section)
- `commands/sync-lovable.md` - Refactored to delegate to agent
- `agents/sync-agent.md` - New file (19KB comprehensive documentation)
- `CHANGELOG.md` - This entry

**Lines Changed**:
- Removed: 22 lines (duplication in skill)
- Added: 835 lines (new agent)
- Modified: 342 lines (refactored command)
- **Net**: +1,155 lines of structured, maintainable code

### Migration Guide

**No migration needed** - This is a non-breaking release. All existing workflows continue to work identically.

**Optional**: Review the new sync-agent documentation to understand the improved architecture:
- `agents/sync-agent.md` - Agent capabilities and modes
- `commands/sync-lovable.md` - Updated command documentation

### What's Next

Future agents enabled by this foundation:
1. **deployment-agent** - Autonomous deployment verification and rollback
2. **migration-validator** - SQL analysis and impact assessment
3. **codebase-analyzer** - Project health checks and optimization suggestions

---

## [1.5.0] - 2025-01-04

### Added

#### Auto-Sync Hook (Start Event)
- **New auto-sync hook** keeps local repo synchronized with GitHub
- Automatically pulls latest changes from GitHub when Claude starts working
- Only runs on main branch with no uncommitted changes
- Uses `git pull --rebase` to maintain clean history
- Gracefully handles conflicts - aborts and notifies user if conflicts detected
- Prevents diverged branch issues by checking if local/remote have diverged
- Added `hooks/auto-sync.sh` script that runs on Start event

#### Benefits of Auto-Sync
- ✅ **Always work on latest code** - Pulls changes before Claude starts
- ✅ **Prevents conflicts** - Detects diverged branches and warns user
- ✅ **Safe operation** - Only pulls when no uncommitted changes exist
- ✅ **Seamless workflow** - Happens automatically in the background
- ✅ **Network resilient** - Exits silently if GitHub is unreachable

### Changed

#### Hook-Based Auto-Push Implementation
- **Auto-push now uses Claude Code hooks** instead of skill-based logic
- More reliable and deterministic - hooks always run when Claude finishes responding
- Auto-push logic moved from `skills/lovable/SKILL.md` to `hooks/auto-push.sh`
- New `hooks/hooks.json` configuration file defines Stop event hook
- Hook automatically commits and pushes changes when `Auto-Push to GitHub: on` in CLAUDE.md

#### Benefits of This Change
- ✅ **More reliable** - Hooks guarantee execution vs. Claude sometimes forgetting
- ✅ **Deterministic** - Always runs on Stop event, no conditional logic needed
- ✅ **Cleaner architecture** - Separation of concerns between skills and automation
- ✅ **Better user experience** - Users don't need to remind Claude to push
- ✅ **Maintains all safety checks** - Same conditions apply (main branch, changes exist, enabled in CLAUDE.md)

#### Technical Details
- Added `hooks/` directory with `hooks.json`, `auto-sync.sh`, and `auto-push.sh`
- Updated `.claude-plugin/plugin.json` to reference hooks
- Simplified `skills/lovable/SKILL.md` - removed manual auto-push instructions
- Auto-push hook checks for `Auto-Push to GitHub: on` in user's CLAUDE.md
- Auto-sync hook runs on Start event, auto-push runs on Stop event
- Both hooks exit silently if conditions aren't met
- Smart commit messages based on changed files (edge functions, migrations, frontend)

## [1.4.1] - 2025-01-04

### Fixed

#### Auto-Push Independence
- **Auto-push is now independent of yolo mode** - can be enabled/disabled separately
- Auto-push can be ON while yolo mode is OFF (for manual deployment workflow)
- Yolo mode still REQUIRES auto-push to be ON (enforced when enabling)
- Disabling yolo mode no longer disables auto-push

#### Updated Question Flow in /init-lovable
- Moved auto-push question (Q9) before yolo mode question (Q11)
- Auto-push is now asked independently, not conditionally
- Yolo mode checks for auto-push and prompts to enable if needed
- Clearer separation of concerns in CLAUDE.md template

#### Updated /yolo Command
- Removed `--auto-push` and `--no-auto-push` flags (auto-push configured separately)
- Added auto-push requirement check when enabling yolo mode
- Prompts user to enable auto-push if it's off
- Disabling yolo mode preserves auto-push setting

#### Benefits of This Change
- ✅ Use auto-push without yolo mode for faster git workflow
- ✅ Clearer mental model - two independent features with one dependency
- ✅ More flexibility in configuration options

## [1.4.0] - 2025-01-04

### Added

#### Auto-Push to GitHub Feature
- **Automatic commit and push after task completion** - Claude automatically commits and pushes your changes to GitHub after successfully completing a task
- **New auto-push question in `/init-lovable`** - During initialization, users are asked if they want auto-push enabled (default: yes, recommended)
- **New `Auto-Push to GitHub` setting** in CLAUDE.md Yolo Mode Configuration
  - Enabled by default when yolo mode is on
  - Disable with `--no-auto-push` flag if you prefer manual git commands
- **Smart commit messages** - Claude creates descriptive commit messages following your project's commit style
- **Safety checks before pushing**:
  - Verifies task completed successfully (no errors)
  - Checks for actual file changes
  - Confirms on main branch
  - Never force pushes without permission

#### Complete Workflow Automation
With auto-push enabled alongside yolo mode, the full workflow is now automated:
```
1. You ask Claude to make changes
2. Claude completes the task successfully
3. Claude automatically commits with descriptive message
4. Claude pushes to main branch on GitHub
5. GitHub syncs to Lovable (frontend changes)
6. Auto-deploy triggers for backend changes (if enabled)
```

#### Enhanced Commands
- Updated `/yolo` command with `--auto-push` and `--no-auto-push` flags
- Updated syntax: `/yolo [on|off] [--auto-push|--no-auto-push] [--auto-deploy|--no-auto-deploy] [--testing|--no-testing] [--debug]`
- Auto-push instructions added to lovable skill

### Benefits
- ✅ **Zero manual git commands** - No more forgetting to commit/push
- ✅ **Instant sync** to GitHub → Lovable
- ✅ **Seamless workflow** from code changes to production
- ✅ **Works perfectly** with existing auto-deploy feature

### How It Works

When auto-push is enabled, after each successful task:
1. Claude checks `git status` for changes
2. If changes exist, stages all files with `git add .`
3. Creates a descriptive commit message
4. Commits with `git commit -m "message"`
5. Pushes to main with `git push origin main`
6. If yolo mode auto-deploy is also on, deployment triggers automatically

## [1.3.0] - 2025-01-03

### Added

#### Automatic Deployment After Git Push (Auto-Deploy)
- **No more manual `/deploy-edge` commands** - Claude automatically detects backend changes after `git push` and deploys them
- **New `auto_deploy` setting** in CLAUDE.md Yolo Mode Configuration
  - Enabled by default when yolo mode is on
  - Disable with `--no-auto-deploy` flag if you prefer manual commands
- **Intelligent detection** - Only triggers for backend file changes:
  - Edge functions: `supabase/functions/**/*`
  - Migrations: `supabase/migrations/*.sql`
- **Order-aware deployment** - Applies migrations before deploying functions when both are changed

#### Enhanced Yolo Mode Commands
- New flag: `--auto-deploy` (default) - Enable automatic deployment after git push
- New flag: `--no-auto-deploy` - Require manual `/deploy-edge` or `/apply-migration` commands
- Updated syntax: `/yolo [on|off] [--auto-deploy|--no-auto-deploy] [--testing|--no-testing] [--debug]`

#### Improved Graceful Fallbacks
- **Never blocks the user** - Every automation failure provides manual prompt as fallback
- **Context-specific error messages** - Clear explanations of what went wrong
- **Actionable troubleshooting** - Suggestions based on error type
- **Recovery options** - Retry, switch modes, or complete manually

### How Auto-Deploy Works

```
1. You push backend changes to main:
   git push origin main

2. Claude automatically detects:
   ✅ Push successful
   ✅ Backend files changed: supabase/functions/send-email/
   ✅ yolo_mode: on, auto_deploy: on

3. Deployment starts automatically:
   🤖 Auto-deploy: Backend changes detected, starting deployment...
   ⏳ Step 1/7: Navigating to Lovable project...
   [... automation runs ...]
   ✅ Complete! Edge function deployed and verified.
```

### New Reference Files
- `skills/yolo/references/post-push-automation.md`
  - Complete auto-deploy implementation details
  - User notification templates
  - Graceful fallback handling
  - Configuration options

### Updated Files
- `skills/yolo/SKILL.md` - Added auto-deploy activation triggers
- `skills/yolo/references/detection-logic.md` - Post-push detection implementation
- `skills/yolo/references/automation-workflows.md` - Graceful fallback strategy section
- `skills/lovable/references/CLAUDE-template.md` - Auto-Deploy configuration option
- `commands/yolo.md` - New `--auto-deploy` and `--no-auto-deploy` flags

### Example Configurations

**Full automation (recommended):**
```
/lovable:yolo on
# Auto-deploy after git push, with testing
```

**Manual deploy commands only:**
```
/lovable:yolo on --no-auto-deploy
# Browser automation for /deploy-edge, but not automatic
```

---

## [1.2.0] - 2024-01-15

### Added

#### Enhanced Secret Management
- **Automated secret detection** during `/lovable:init` - Scans codebase for environment variables
  - Detects `Deno.env.get("SECRET")` patterns in Edge Functions
  - Parses `.env.example` files for configuration templates
  - Context-based inference for common services (OpenAI, Stripe, Resend, Twilio, SendGrid, AWS)
- **Browser automation for secret extraction** - Automatically fetch existing secrets from Lovable Cloud
  - Navigate to Cloud → Secrets page
  - Extract secret names with graceful fallback to manual entry
  - 30-second timeout, never blocks workflow
- **Enhanced CLAUDE.md template** - Better tracking of secret status
  - Added Status column (✅ In Lovable Cloud / ⚠️ Not configured)
  - Added "Used In" column showing which functions use each secret
  - Legend explaining status indicators
  - Clear setup instructions

#### New `/lovable:sync` Command
- Re-synchronize CLAUDE.md with current Lovable Cloud state
- Refresh secrets, functions, and project settings
- Detects new secrets added by team members
- Updates configuration while preserving user notes and conventions
- Command flags: `--apply`, `--dry-run`, `--manual`, `--debug`, `--force-rescan`

#### Improved Init Flow
- **Reorganized questions** - Better logical grouping
  - Q5: Lovable Project URL (now asks all users, enables secret extraction)
  - Q6: Secret Detection Method (auto-detect or manual)
  - Questions 7-12: Reordered for clarity
- **Auto-run tests configuration** - Part of yolo mode setup
  - Detect test framework automatically (jest, vitest, npm test)
  - Run tests after every git push to main branch
  - Configuration stored in CLAUDE.md Yolo section
  - Independent of backend deployments

#### Better Secret Validation
- Enhanced `/lovable:deploy-edge` to validate secrets before deployment
- Cross-reference detected secrets with CLAUDE.md status
- Warn about missing secrets to prevent deployment failures
- Show which secrets are already configured in Lovable Cloud

### Improved

- Secret detection algorithm now detects purpose/usage context
- Error handling reuses proven patterns from existing automation
- Browser automation timeout strategies refined (45 seconds max, never blocks)
- CLAUDE.md updates preserve all user customizations (conventions, notes, custom prompts)

### Documentation

- New reference file: `skills/lovable/references/secret-detection.md`
  - Complete secret detection patterns and algorithms
  - Context-based inference logic for services
  - Merge and deduplication strategies
  - Edge case handling
- New reference file: `skills/yolo/references/secrets-extraction.md`
  - Browser automation workflow for Cloud → Secrets
  - Element selectors and extraction patterns
  - Error handling and timeout strategies
  - Integration with init flow
- Updated `skills/lovable/references/CLAUDE-template.md`
  - Enhanced Secrets table with Status and Used In columns
  - Enhanced Edge Functions table with Status indicators
  - New legend and setup instructions
- Updated `commands/deploy-edge.md`
  - Improved secret validation workflow
  - Better error messages for missing secrets
- Updated README.md
  - Added `/lovable:sync` command documentation

### Technical

- Reuses existing automation patterns - No duplicated logic
- Graceful fallback for all browser automation operations
- Smart caching to reduce repeated automation runs
- Debug mode for troubleshooting automation workflows

## [1.1.0] - Previous Release

- Added yolo mode (v1.1.0) - automated browser-based Lovable deployments
- Initial version with basic commands and skill integration

---

## Upgrading from 1.1.0 to 1.2.0

### For Users in Claude Code

1. Open Claude Code
2. Run: `/plugin install lovable@10k-digital --scope project --force`
3. Or: `/plugin install lovable@10k-digital --force` (for user-level installation)
4. Restart Claude Code

### What's New for Your Existing Projects

- Run `/lovable:sync` to refresh your CLAUDE.md with latest secrets and settings
- Consider re-running `/lovable:init` to set up auto-run tests (optional)
- Existing CLAUDE.md files are fully compatible (no breaking changes)

### Benefits

- ✅ Automatic secret detection saves time
- ✅ `/lovable:sync` keeps your config in sync with team changes
- ✅ Better secret status tracking prevents deployment failures
- ✅ Auto-run tests catch issues early
- ✅ Improved init flow for new projects

---

## Version Format

This project follows [Semantic Versioning](https://semver.org/):
- MAJOR: Breaking changes
- MINOR: New features, backwards compatible
- PATCH: Bug fixes, backwards compatible
