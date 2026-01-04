# Changelog

All notable changes to the Lovable Claude Code plugin will be documented in this file.

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
