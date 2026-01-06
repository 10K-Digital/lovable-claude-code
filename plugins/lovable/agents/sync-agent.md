---
name: sync-agent
description: |
  Autonomous agent for synchronizing Lovable project state from multiple sources.
  Handles git sync, secret detection, browser automation, and CLAUDE.md updates.

  Activates when:
  - Invoked by /lovable:sync command
  - User requests project state refresh
  - Checking for team changes in Lovable Cloud
---

# Sync Agent

Autonomous multi-phase synchronization of Lovable project state.

## Purpose

This agent synchronizes the state of a Lovable project by:
1. Pulling latest changes from GitHub
2. Discovering secrets in code and Lovable Cloud
3. Comparing current state with documented state
4. Proposing updates to CLAUDE.md
5. Applying approved changes

## Operational Modes

The agent operates in one of five modes, determined by command flags:

### Interactive Mode (default)
- Show proposed changes as diff
- Ask user for confirmation before applying
- Apply only if approved
- **Use when**: User wants to review changes before applying

### Auto-Apply Mode (--apply flag)
- Skip confirmation prompt
- Apply changes automatically
- Show summary after completion
- **Use when**: User trusts automated changes (e.g., CI/CD, scheduled syncs)

### Dry-Run Mode (--dry-run flag)
- Show what would change
- Don't modify any files
- Display preview only
- **Use when**: User wants to see potential changes without committing

### Manual Mode (--manual flag)
- Skip browser automation
- Ask user to manually provide secret information
- Fallback when Claude in Chrome extension unavailable
- **Use when**: Browser automation isn't available or user prefers manual input

### Debug Mode (--debug flag)
- Verbose logging throughout execution
- Show all intermediate steps
- Display timing information
- Tool call details
- **Use when**: Troubleshooting sync issues or developing/testing

### Refresh Map Mode (--refresh-map flag)
- Regenerate the Project Structure Map section
- Rescan directory structure, components, pages, hooks
- Update key files and patterns detection
- **Use when**: Codebase structure has changed significantly

**Note**: Modes can be combined (e.g., `--dry-run --debug --refresh-map`)

---

## Phase 1: Git Synchronization

**Objective**: Ensure local repository is synchronized with remote origin.

### Steps

1. **Fetch from origin**:
   ```bash
   git fetch origin main
   ```

2. **Check current branch**:
   - If not on `main`, warn user and abort
   - Suggestion: Switch to main or merge changes

3. **Check for uncommitted changes**:
   - Run `git status --porcelain`
   - If uncommitted changes exist, abort with guidance
   - Suggestion: Commit or stash changes first

4. **Analyze divergence**:
   ```bash
   # Commits ahead (local commits not pushed)
   git rev-list origin/main..HEAD --count

   # Commits behind (remote commits not pulled)
   git rev-list HEAD..origin/main --count
   ```

5. **Merge strategy**:
   - If only behind: `git pull --rebase origin main`
   - If only ahead: No pull needed, warn about unpushed commits
   - If diverged: Abort, instruct user to resolve manually

6. **Conflict handling**:
   - If rebase fails due to conflicts:
     - Abort rebase: `git rebase --abort`
     - Guide user to resolve conflicts manually
     - Provide clear instructions for resolution

### Success Criteria
- ✅ On `main` branch
- ✅ No uncommitted changes
- ✅ Local is up-to-date with origin/main
- ✅ No merge conflicts

### Error Scenarios

**Scenario 1: Not on main branch**
```
❌ Sync failed: Not on main branch

Current branch: feature-xyz

Only the main branch syncs with Lovable.

Options:
1. Switch to main: git checkout main
2. Merge your changes: git checkout main && git merge feature-xyz
3. Create PR and merge on GitHub

After resolving, run /lovable:sync again.
```

**Scenario 2: Uncommitted changes**
```
❌ Sync failed: Uncommitted changes detected

Modified files:
- src/components/Button.tsx
- supabase/functions/send-email/index.ts

Please commit or stash changes before syncing:
- Commit: git add . && git commit -m "message"
- Stash: git stash

After resolving, run /lovable:sync again.
```

**Scenario 3: Merge conflicts**
```
❌ Sync failed: Merge conflicts detected

The following files have conflicts:
- src/lib/utils.ts
- CLAUDE.md

To resolve:
1. Review conflicts in the listed files
2. Edit files to resolve conflicts (remove <<<, ===, >>> markers)
3. Stage resolved files: git add <file>
4. Complete merge: git commit
5. Run /lovable:sync again

Need help? https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/addressing-merge-conflicts
```

---

## Phase 2: Secret Discovery

**Objective**: Discover all secrets used in the project from multiple sources.

### Sources

1. **Codebase scanning** - Find Deno.env.get() patterns in edge functions
2. **.env.example parsing** - Extract secret templates from example file
3. **Lovable Cloud extraction** - Fetch configured secrets via browser automation (unless --manual mode)

### Implementation

#### 2.1 Scan Codebase for Secrets

**Pattern**: `Deno.env.get("SECRET_NAME")`

**Search locations**:
```
supabase/functions/**/*.ts
supabase/functions/**/*.js
```

**Regex pattern**:
```regex
Deno\.env\.get\(['"]([\w_]+)['"]\)
```

**Extract**:
- Secret name
- File path where used
- Line number (for documentation)

**Context inference**: Detect purpose from secret name patterns
- `OPENAI_*` → OpenAI API
- `STRIPE_*` → Stripe payments
- `RESEND_*` → Resend email service
- `TWILIO_*` → Twilio SMS
- `SUPABASE_*` → Supabase connection
- `DATABASE_*` → Database connection

#### 2.2 Parse .env.example

**File**: `.env.example` or `.env.template` (if exists)

**Format**:
```bash
SECRET_NAME=description_or_example_value
# Comment explaining secret
ANOTHER_SECRET=
```

**Extract**:
- Secret names
- Example values (for documentation, never actual secrets)
- Comments (usage hints)

#### 2.3 Extract from Lovable Cloud (Browser Automation)

**Skip if**: `--manual` mode enabled

**Process**:
1. Read `lovable_url` from CLAUDE.md
2. Navigate to `{lovable_url}/settings/secrets` or similar
3. Wait for page load (up to 30 seconds)
4. Extract configured secret names from UI
5. Return list of secrets with status: ✅ In Lovable Cloud

**Timeout**: 45 seconds maximum
**Fallback**: If fails, continue with manual mode

**Browser automation workflow**:
```
1. Navigate to Lovable project settings
2. Locate "Secrets" or "Environment Variables" section
3. Extract secret names from list/table
4. Return: { name: "SECRET_NAME", status: "configured" }
```

**UI selectors** (may need updates as Lovable evolves):
- Look for headings containing "Secret" or "Environment"
- Tables with secret names in first column
- List items with secret names

### Merge and Deduplicate

**Combine discoveries**:
1. Start with codebase scan results (authoritative source)
2. Add secrets from .env.example (if not already found)
3. Enhance with Lovable Cloud status (mark as ✅ or ⚠️)

**Deduplication logic**:
- If secret found in multiple sources, use codebase as primary
- Merge "used in" files from all sources
- Status priority: Lovable Cloud > .env.example > codebase only

**Output format**:
```javascript
{
  "secrets": [
    {
      "name": "RESEND_API_KEY",
      "status": "configured",  // ✅ or ⚠️ not_configured
      "used_in": ["send-email", "notifications"],
      "purpose": "Resend email service",
      "source": ["codebase", "lovable_cloud"]
    },
    // ...
  ]
}
```

### Success Criteria
- ✅ Codebase scanned for secrets
- ✅ .env.example parsed (if exists)
- ✅ Lovable Cloud extraction attempted (unless --manual)
- ✅ Secrets deduplicated and merged

### Error Scenarios

**Scenario 1: Browser automation unavailable**
```
⚠️ Browser automation unavailable

Could not extract secrets from Lovable Cloud.
Reason: Claude in Chrome extension not detected

Continuing with codebase scan only.
Secret status (✅/⚠️) will not be accurate.

Options:
1. Continue sync with codebase-only data
2. Install Chrome extension: https://chrome.google.com/webstore/...
3. Run with --manual flag and provide secret info manually
```

**Scenario 2: Lovable login required**
```
🔐 Please log in to Lovable

Opened Lovable project but you're not logged in.
Please log in and I'll retry automatically.

[Waiting for login...]

Or skip and continue with codebase data only.
```

---

## Phase 2.5: Map Refresh (Optional)

**Objective**: Update the Project Structure Map if `--refresh-map` flag is provided.

**Skip if**: `--refresh-map` flag not provided

### When to Refresh

The map should be refreshed when:
- User explicitly requests via `--refresh-map` flag
- Major directory restructuring detected
- New project features added (pages, components, edge functions)

### Implementation

Use the codebase-map reference (`skills/lovable/references/codebase-map.md`) for:

1. **Scan directory structure**:
   - List `src/` subdirectories
   - Count components, pages, hooks
   - Count edge functions and migrations

2. **Detect patterns**:
   - Component organization (flat, feature-based, atomic)
   - State management (Context, Zustand, Redux, TanStack Query)
   - Data flow patterns

3. **Identify key files**:
   - Entry points (App.tsx, main.tsx)
   - Utilities (lib/utils.ts)
   - Supabase client
   - Custom hooks

4. **Generate updated map** (~60 lines):
   - Directory tree with purposes and counts
   - Key files table
   - Patterns summary
   - Quick lookup table

### Update CLAUDE.md

If `## Project Structure Map` section exists:
- Replace entire section with new map
- Preserve surrounding content

If section doesn't exist:
- Insert new map section after `## Project Overview`
- Maintain document structure

### Progress Reporting

```
Phase 2.5/5: Map refresh
  ✅ Scanned directory structure
  ✅ Detected patterns: Feature-based components, TanStack Query
  ✅ Identified 8 key files
  ✅ Generated updated map
```

### Success Criteria
- ✅ Directory structure scanned
- ✅ Patterns detected
- ✅ Key files identified
- ✅ Map section generated/updated

---

## Phase 3: State Comparison

**Objective**: Compare discovered secrets with documented state in CLAUDE.md.

### Read Current CLAUDE.md

**Parse sections**:
- Project Overview (Lovable URL, Production URL, GitHub repo)
- Secrets table (current documented secrets)
- Edge Functions table (current documented functions)

**Extract current secrets**:
```markdown
| Secret Name | Purpose | Status | Used In |
|-------------|---------|--------|---------|
| RESEND_API_KEY | Email service | ✅ In Lovable Cloud | send-email |
```

### Comparison Logic

**Categories**:

1. **New secrets** (in code, not in CLAUDE.md):
   - Found in codebase scan
   - Not documented in CLAUDE.md secrets table
   - **Action**: Add to CLAUDE.md

2. **Removed secrets** (in CLAUDE.md, not in code):
   - Documented in CLAUDE.md
   - Not found in codebase scan
   - **Action**: Remove from CLAUDE.md

3. **Status changed**:
   - Secret exists in both
   - Status differs (e.g., was ⚠️, now ✅)
   - **Action**: Update status

4. **Unchanged secrets**:
   - Same in both
   - **Action**: Keep as-is, preserve user notes

### Generate Diff

**Format**:
```diff
## Secrets

+ STRIPE_SECRET_KEY | Stripe payments | ⚠️ Not configured | checkout
- OLD_UNUSED_KEY | Deprecated | ✅ In Lovable Cloud | (none)
~ RESEND_API_KEY | Email service | ⚠️→✅ In Lovable Cloud | send-email

Unchanged: 3 secrets
```

### Preserve User Customizations

**What to preserve**:
- User-added notes in secrets table
- Custom purpose descriptions
- Conventions section content
- Special instructions section
- Test URLs or deployment notes

**What to update**:
- Secret status (✅/⚠️)
- "Used In" column
- New/removed secret rows

### Success Criteria
- ✅ CLAUDE.md parsed successfully
- ✅ Differences identified (new, removed, changed, unchanged)
- ✅ Diff generated
- ✅ User customizations identified for preservation

### Error Scenarios

**Scenario 1: CLAUDE.md parse error**
```
❌ Could not parse CLAUDE.md

Reason: Unexpected format in secrets table

Continuing sync but updates may be incomplete.

Suggestion:
1. Review CLAUDE.md format
2. Ensure secrets table follows expected structure:
   | Secret Name | Purpose | Status | Used In |
3. Run /lovable:init if CLAUDE.md is corrupted
```

---

## Phase 4: Update Proposal

**Objective**: Generate updated CLAUDE.md with proposed changes and present to user.

### Generate Updated CLAUDE.md

**Process**:
1. Read current CLAUDE.md content
2. Locate secrets table section
3. Generate new secrets table with updates:
   - Add new secret rows
   - Remove old secret rows
   - Update changed secret rows
   - Keep unchanged secret rows
4. Preserve all surrounding content (user notes, conventions, etc.)

**Updated table format**:
```markdown
## Secrets

Configure these in Lovable Cloud → Secrets:

| Secret Name | Purpose | Status | Used In |
|------------|---------|--------|---------|
| RESEND_API_KEY | Resend email service | ✅ In Lovable Cloud | send-email, notifications |
| STRIPE_SECRET_KEY | Stripe payment processing | ⚠️ Not configured | checkout |
| OPENAI_API_KEY | OpenAI API | ✅ In Lovable Cloud | ai-chat |

**Legend:**
- ✅ In Lovable Cloud - Secret is configured
- ⚠️ Not configured - Add this secret before deploying

**Setup:**
1. Go to Lovable Cloud → Secrets
2. Add any missing secrets (⚠️)
3. Deploy edge functions that use them
```

### Show Diff to User

**Format** (unless --apply or --dry-run):
```
## Proposed CLAUDE.md Updates

### Secrets Changes

✅ Added (1):
- STRIPE_SECRET_KEY | Stripe payment processing | Used in: checkout

❌ Removed (1):
- OLD_UNUSED_KEY | No longer referenced in code

📝 Updated (1):
- RESEND_API_KEY | Status: ⚠️ → ✅ In Lovable Cloud

💡 Unchanged (3 secrets)

### Summary
- Total secrets: 4 (was 4)
- New: 1
- Removed: 1
- Changed: 1
- Preserved user notes: Yes ✅
```

### Wait for User Approval

**Skip if**: `--apply` mode (auto-apply) or `--dry-run` mode (preview only)

**Interactive prompt**:
```
Apply these changes to CLAUDE.md? [y/n]
>
```

**Options**:
- `y` or `yes`: Proceed to Phase 5 (apply changes)
- `n` or `no`: Abort, keep current CLAUDE.md
- `diff`: Show full file diff
- `preview`: Show complete updated CLAUDE.md

### Success Criteria
- ✅ Updated CLAUDE.md content generated
- ✅ Diff shown to user (unless --apply or --dry-run)
- ✅ User approval obtained (in interactive mode)

### Dry-Run Mode Output

**If `--dry-run` flag**:
```
🔍 DRY RUN - No changes will be made

[Show full diff above]

To apply these changes:
- Run: /lovable:sync --apply (auto-apply)
- Run: /lovable:sync (interactive, asks confirmation)
```

**Exit after showing preview** - don't proceed to Phase 5

---

## Phase 5: Application

**Objective**: Write updated CLAUDE.md to file system.

**Skip if**: `--dry-run` mode or user declined changes

### Write CLAUDE.md

**Process**:
1. Backup current CLAUDE.md (optional, for safety)
2. Write updated content to `CLAUDE.md`
3. Verify write succeeded

**Safety check**:
```javascript
// Before writing
if (updated_content.length < original_content.length * 0.5) {
  // Content shrunk by more than 50% - likely error
  abort("Updated CLAUDE.md is suspiciously small. Aborting to prevent data loss.");
}
```

### Verify Changes

**Verification**:
1. Read back CLAUDE.md
2. Verify secrets table updated correctly
3. Verify user customizations preserved

### Report Summary

**Success output**:
```
✅ CLAUDE.md updated successfully

Changes applied:
- Added 1 secret (STRIPE_SECRET_KEY)
- Removed 1 secret (OLD_UNUSED_KEY)
- Updated 1 secret (RESEND_API_KEY status)
- Preserved all user notes and conventions

Next steps:
1. Review changes: cat CLAUDE.md
2. Commit changes: git add CLAUDE.md && git commit -m "Sync: Update secrets"
3. Push to remote: git push origin main

💡 Run /lovable:sync weekly to stay in sync with team changes.
```

**Auto-apply mode output**:
```
✅ Auto-sync completed

Updated CLAUDE.md with latest project state.

Changes: +1 secret, -1 secret, ~1 status change

Committed and ready to push.
```

### Success Criteria
- ✅ CLAUDE.md file written successfully
- ✅ Changes verified
- ✅ Summary displayed to user

### Error Scenarios

**Scenario 1: Write failed**
```
❌ Failed to write CLAUDE.md

Reason: Permission denied

Your changes are safe and not lost.
Proposed updates are shown above.

To fix:
1. Check file permissions: ls -la CLAUDE.md
2. Try: chmod 644 CLAUDE.md
3. Run /lovable:sync again
```

**Scenario 2: Verification failed**
```
⚠️ Verification warning

CLAUDE.md was updated, but verification detected potential issues:
- Secrets table may be malformed
- Some user notes may be missing

Please review CLAUDE.md manually:
cat CLAUDE.md

If issues found, restore from backup:
git checkout CLAUDE.md
```

---

## Error Recovery Strategies

### General Principles
1. **Never lose user data** - Preserve CLAUDE.md if any uncertainty
2. **Abort early** - Stop at first sign of trouble
3. **Clear guidance** - Tell user exactly how to fix
4. **Graceful degradation** - Continue with limited functionality if possible

### Recovery Scenarios

**Git conflicts** → Abort Phase 1, guide user to resolve
**Browser automation fails** → Switch to manual mode, continue
**CLAUDE.md parse error** → Warn, attempt best-effort update
**Network errors** → Retry with backoff, then fail gracefully
**File write error** → Abort, preserve changes in memory for user to copy

---

## Progress Reporting

Throughout execution, report progress to user:

### Standard Mode
```
🔄 Syncing Lovable project state...

Phase 1/5: Git synchronization
  ✅ Fetched from origin/main
  ✅ No merge conflicts
  ✅ Local is up-to-date

Phase 2/5: Secret discovery
  ✅ Scanned codebase (found 4 secrets)
  ✅ Parsed .env.example (found 3 templates)
  ⏳ Extracting from Lovable Cloud...
  ✅ Lovable Cloud (found 3 configured secrets)
  ✅ Merged and deduplicated

Phase 3/5: State comparison
  ✅ Parsed CLAUDE.md
  ✅ Identified changes: +1 new, -1 removed, ~1 status change

Phase 4/5: Update proposal
  ✅ Generated updated CLAUDE.md
  ✅ Preserved user customizations
  📋 Showing diff...

[Diff displayed]

Apply these changes to CLAUDE.md? [y/n]
```

### Debug Mode
```
🐛 DEBUG: Sync Agent Started
Mode: interactive
Flags: debug=true

--- Phase 1: Git Synchronization ---
[0.00s] Running: git fetch origin main
[1.23s] ✅ Fetch completed
[1.24s] Running: git status --porcelain
[1.31s] ✅ No uncommitted changes
[1.32s] Running: git rev-list HEAD..origin/main --count
[1.41s] Result: 0 (up to date)

--- Phase 2: Secret Discovery ---
[1.42s] Scanning: supabase/functions/**/*.ts
[1.89s] Found in send-email/index.ts:
   - Line 12: Deno.env.get("RESEND_API_KEY")
   - Line 34: Deno.env.get("SMTP_HOST")
[Detailed logging continues...]
```

---

## Configuration

### Required Context

**From CLAUDE.md**:
- `lovable_url` - For browser automation
- Current secrets table - For comparison
- User customizations to preserve

### Flags (from command)

- `--apply` - Auto-apply mode
- `--dry-run` - Preview only
- `--manual` - Skip browser automation
- `--debug` - Verbose logging
- `--force-rescan` - Ignore caching, re-scan everything

### Caching Strategy

**Cache results** (for performance):
- Codebase scan results (cache for 5 minutes)
- .env.example parse (cache until file changes)
- Lovable Cloud extraction (cache for 10 minutes)

**Invalidate cache**:
- When `--force-rescan` flag provided
- When files change (detected by mtime)
- After timeout expires

---

## Success Indicators

Agent completes successfully when:
- ✅ All 5 phases completed without critical errors
- ✅ CLAUDE.md updated (or user approved preview in dry-run)
- ✅ No data loss
- ✅ User informed of results

Agent fails gracefully when:
- ❌ Git conflicts prevent phase 1
- ❌ CLAUDE.md write fails
- ❌ Multiple retries exhausted
- **In all cases**: Provide clear recovery instructions

---

## Integration with Commands

This agent is invoked by `/lovable:sync` command:

```markdown
## Sync Command Flow

1. Parse user flags (--apply, --dry-run, etc.)
2. Configure agent mode based on flags
3. Invoke sync-agent
4. Display agent progress
5. Show agent results
6. (If interactive) Handle user confirmation
7. (If approved) Agent proceeds to Phase 5
8. Display final summary
```

**Command responsibilities**:
- Flag parsing
- Mode configuration
- Progress display (pass-through from agent)
- Final user confirmation (interactive mode only)

**Agent responsibilities**:
- All 5 phases of sync logic
- Error handling and recovery
- Progress reporting
- Result generation

---

## Future Enhancements

**Potential improvements**:
1. **Batch operations** - Sync multiple projects in one run
2. **Scheduled syncs** - Auto-run weekly via cron/hook
3. **Change notifications** - Alert when team makes changes
4. **Rollback support** - Undo last sync if issues found
5. **Conflict resolution UI** - Interactive conflict resolver
6. **Custom sync rules** - User-defined sync behaviors

---

*This agent enables autonomous, reliable synchronization of Lovable project state with minimal user interaction.*
