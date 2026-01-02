---
description: Re-sync secrets and backend information from Lovable Cloud. Updates CLAUDE.md with latest project state using browser automation and manual fallback.
---

# Sync Lovable Project State

Re-synchronize CLAUDE.md with current state from Lovable Cloud, including secrets, Edge Functions, and project information.

## Overview

The sync command refreshes your project configuration by:
1. Connecting to Lovable Cloud (if URL available)
2. Extracting current secrets, functions, and settings
3. Comparing with CLAUDE.md to detect changes
4. Updating CLAUDE.md with latest information
5. Reporting what changed and what needs action

## Existing Workflows Reused

This command reuses browser automation and detection patterns from the init flow:

| Component | Source | Reuses |
|-----------|--------|--------|
| **Secrets Extraction** | `skills/yolo/references/secrets-extraction.md` | Browser automation to navigate to Cloud → Secrets, extract secret names, fallback to manual |
| **Secret Detection** | `skills/lovable/references/secret-detection.md` | Detection patterns for extracting secrets from codebase, purpose inference, merging results |
| **Error Handling** | `secrets-extraction.md` + `secret-detection.md` | Timeout strategies, login handling, fallback mechanisms |
| **CLAUDE.md Updates** | `skills/lovable/references/CLAUDE-template.md` | Template format for Secrets table with Status/Used In columns |

**No new automation patterns needed** - Reuses proven workflows from init and yolo skills.

## When to Use

Use `/lovable:sync` when:
- ✅ Secrets were added/removed in Lovable Cloud directly
- ✅ Edge Functions were added via Lovable UI
- ✅ Want to verify CLAUDE.md matches Lovable Cloud
- ✅ Coming back to a project after a break
- ✅ Collaborating with team (others added secrets/functions)
- ✅ Production URL or settings changed
- ✅ CLAUDE.md file was deleted or corrupted

## Instructions

**High-level flow:**

1. **Sync upstream changes** - Fetch any commits from GitHub (from team or Lovable):
   - Check if remote has new commits
   - Fetch from origin
   - Merge if needed, handle conflicts
   - Report what was synced down

2. **Read CLAUDE.md** - Get current state (Lovable URL, secrets, functions)

3. **Re-run secret detection** - Use same logic as `/lovable:init`:
   - Codebase scanning (Deno.env.get patterns, .env.example)
   - Browser automation (if Lovable URL available)
   - Context-based inference (OpenAI, Stripe, etc.)

4. **Compare results** - New/removed/unchanged secrets

5. **Update CLAUDE.md** - Add new secrets, update status, preserve user notes

6. **Report changes** - Show what changed and recommendations

**Key difference from init:**
- Init: Creates new CLAUDE.md from scratch
- Sync: Updates existing CLAUDE.md, preserves all user customizations
- Sync also pulls down changes from team/GitHub

**Reused logic:**
- `secret-detection.md` - Scan codebase and infer secrets
- `secrets-extraction.md` - Browser automation to Cloud → Secrets
- Same comparison algorithm
- Same CLAUDE.md template format

## Detailed Workflow

### Step 1: Sync Upstream Changes from GitHub

**Check for remote commits (from team or Lovable UI):**

```bash
# 1. Fetch latest from remote
git fetch origin

# 2. Check if local is behind remote
git rev-list --count HEAD..origin/main
# If output > 0, there are new commits to pull
```

**Merge strategy:**

```bash
# 3. If new commits exist:
git merge origin/main

# 4. If merge conflict occurs:
#    - Show user which files have conflicts
#    - Ask: overwrite local with remote OR keep local?
#    - Resolve based on user choice
#    - Complete merge
```

**Handle merge conflicts:**

If conflicts detected:
- **Option A: Accept theirs** (remote/team changes)
  - `git checkout --theirs FILE` for each conflicted file
  - Useful when team made important changes

- **Option B: Keep ours** (local changes)
  - `git checkout --ours FILE` for each conflicted file
  - Useful when local edits are intentional

- **Option C: Manual resolve**
  - User edits files to resolve conflicts manually
  - `git add` resolved files
  - `git merge --continue`

**Report results:**

```
✅ Git Sync Complete

Remote commits pulled: 3
Conflicts: 0
Files updated: 5

Synced from remote:
  - package.json
  - supabase/functions/send-email/index.ts
  - src/components/Email.tsx
  ...

Ready to proceed with CLAUDE.md sync.
```

---

### Step 2: Read CLAUDE.md

Extract current configuration:
- Lovable Project URL (Project Overview)
- Current secrets list and status
- Current Edge Functions list
- Last sync timestamp

If Lovable URL missing: Fall back to manual mode

### Step 3: Run Secret Detection

**Reuse exact same logic as `/lovable:init`:**

1. **Codebase scanning** (from `secret-detection.md`):
   - Scan `supabase/functions/**/*.ts` for `Deno.env.get("SECRET")`
   - Parse `.env.example` files
   - Context-based inference (OpenAI, Stripe, Resend, etc.)

2. **Browser automation** (from `secrets-extraction.md`):
   - If Lovable URL provided: Navigate to `https://lovable.dev/projects/PROJECT_ID?view=cloud`
   - Extract secret names from Cloud → Secrets
   - Timeout: 45 seconds
   - Graceful fallback if unavailable

3. **Merge results**:
   - Combine codebase + browser extraction
   - Deduplicate
   - Note which secrets are in Cloud vs. need setup

**No duplicated logic** - Same detection algorithm as init command

### Step 4: Compare and Report Changes

Compare detection results with current CLAUDE.md:

```
New secrets (detected but not in CLAUDE.md):
  → Alert user, ask to add

Removed secrets (in CLAUDE.md but not detected):
  → Alert user, ask if intentional

Status changes:
  → Update ✅/⚠️ indicators

Unchanged:
  → No action needed
```

Update Secrets table with detected secrets:
- Add new rows for new secrets
- Update status column (✅ In Cloud / ⚠️ Not configured)
- Preserve Purpose and Used In columns

### Step 5: Update CLAUDE.md and Report

If user confirms (or with `--apply` flag):

1. **Update Secrets table:**
   - Add new secrets with Status and Used In columns
   - Preserve Purpose column and user notes
   - Update status indicators (✅/⚠️)

2. **Preserve sections:**
   - **🚨 IMPORTANT: Always Commit and Push to GitHub** (CRITICAL - never remove)
   - Project Conventions (user's notes)
   - Database Tables
   - Special Instructions
   - Yolo Mode Configuration
   - Quick Prompts

3. **Report changes:**
   ```
   ✅ SYNC COMPLETE

   Changes made:
   - Added 2 new secrets to Secrets table
   - Updated status for 4 existing secrets
   - Last sync timestamp updated

   Next steps:
   - Review changes
   - Run /lovable:deploy-edge if needed
   ```

**If automation unavailable:**
```
⚠️ SYNC PARTIAL - Manual mode

Browser automation unavailable after 45 seconds.

Codebase detection found:
- 3 secrets from Edge Functions
- Suggest checking Cloud manually for new ones

CLAUDE.md updated with codebase findings.
To get Lovable Cloud secrets:
  /lovable:sync --manual
```

## Command Flags

```bash
/lovable:sync                    # Interactive: Show changes, ask before updating
/lovable:sync --apply           # Auto-apply all detected changes to CLAUDE.md
/lovable:sync --dry-run         # Show what would change, don't update CLAUDE.md
/lovable:sync --manual          # Skip automation, use manual entry
/lovable:sync --debug           # Show detailed automation logs
/lovable:sync --force-rescan    # Ignore cached results, rescan everything
```

## Manual Sync Mode

If browser automation unavailable or user chooses manual:

```
📋 MANUAL SYNC MODE

Please provide current information from Lovable:

1. Current secrets in Cloud → Secrets:
   (Enter comma-separated secret names, or paste the list)

2. Current Edge Functions:
   (Enter comma-separated function names, or describe)

3. Production URL status:
   (Is https://my-app.lovable.app live? yes/no)

4. Any other changes or notes:
   (Describe what changed since last sync)

I'll compare with CLAUDE.md and update as needed.
```

## Common Use Cases

| Scenario | Trigger | Result |
|----------|---------|--------|
| Team added secrets in Lovable Cloud | `run /lovable:sync` | Secrets added to local CLAUDE.md |
| New Edge Functions created | `run /lovable:sync` | Functions list updated |
| Want to verify everything is in sync | `run /lovable:sync --dry-run` | See what changed, no updates |
| Just synced code, want fresh state | `run /lovable:sync --force-rescan` | Ignore cache, rescan everything |

## Sync Frequency

**Recommended sync intervals:**
- **After team deploys:** Run sync to see what changed
- **Weekly** (if team collaboration): Keep CLAUDE.md fresh
- **Before important deployments:** Verify secrets are configured
- **After Lovable UI changes:** Ensure nothing was missed

**Automatic sync consideration:**
- Could add to yolo mode to sync before each deployment
- Currently manual to avoid unnecessary automation runs

## Error Handling

| Error | Solution |
|-------|----------|
| No Lovable Project URL | Add to CLAUDE.md, then retry |
| Not logged in | Log in to Lovable, then retry |
| Timeout (>45 seconds) | Use `--manual` mode or retry later |
| Page not found (404) | Verify project URL, check access |
| Network issues | Retry or use `--manual` mode |

**All error handling reuses patterns from `secrets-extraction.md`**

## Integration with Other Commands

**Works with:**
- `/lovable:init` - Use sync to refresh after init
- `/lovable:deploy-edge` - Sync before deployment to verify secrets
- `/lovable:apply-migration` - Sync to check DB state
- `/lovable:yolo` - Sync can run before yolo deployments

**Called by:**
- Yolo mode (before deployment, if enabled)
- Auto-sync on project open (future feature)

## Sync Caching

**Results cached for:**
- 5 minutes (quick re-runs within session)
- Cleared when CLAUDE.md is edited
- Cleared when user specifies `--force-rescan`

**Why caching:**
- Reduces browser automation runs
- Improves performance for repeated checks
- User can force fresh check with flag

## Success Criteria

Sync is successful if:
1. ✅ Connects to Lovable (automation or manual)
2. ✅ Extracts current state (secrets, functions, URL)
3. ✅ Compares with CLAUDE.md
4. ✅ Reports changes clearly
5. ✅ Updates CLAUDE.md with new information
6. ✅ Preserves user's custom notes and conventions
7. ✅ Never loses data (adds/updates, not deletes user content)
8. ✅ Provides next steps and recommendations

## Debug Mode

Use `--debug` flag to see detailed automation logs:
- Navigation steps and timings
- Selector matching attempts
- Secret extraction details
- Comparison results
- CLAUDE.md changes

See `secrets-extraction.md` debug output format for examples.

---

This command keeps your project configuration fresh and ensures CLAUDE.md always reflects the current state of your Lovable Cloud project.
