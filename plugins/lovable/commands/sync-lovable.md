---
description: Re-synchronize CLAUDE.md with current state from Lovable Cloud and GitHub. Powered by sync-agent for autonomous multi-phase synchronization.
---

# Sync Lovable Project State

Re-synchronize CLAUDE.md with current state from multiple sources using the autonomous **sync-agent**.

## Overview

The sync command delegates to the **sync-agent** (`agents/sync-agent.md`) for autonomous multi-phase synchronization:
1. Git synchronization (fetch, merge, conflict handling)
2. Secret discovery (codebase scan, .env.example, Lovable Cloud)
3. State comparison (identify changes)
4. Update proposal (generate diff, preserve user customizations)
5. Application (write CLAUDE.md if approved)

## When to Use

Use `/lovable:sync` when:
- ✅ Secrets were added/removed in Lovable Cloud directly
- ✅ Edge Functions were added via Lovable UI
- ✅ Want to verify CLAUDE.md matches Lovable Cloud
- ✅ Coming back to a project after a break
- ✅ Collaborating with team (others added secrets/functions)
- ✅ Production URL or settings changed
- ✅ CLAUDE.md file was deleted or corrupted

**Recommended frequency**: Weekly (if team collaboration), or before important deployments

---

## Command Usage

```bash
/lovable:sync                    # Interactive: Show changes, ask before updating
/lovable:sync --apply           # Auto-apply all detected changes to CLAUDE.md
/lovable:sync --dry-run         # Show what would change, don't update CLAUDE.md
/lovable:sync --manual          # Skip automation, use manual entry
/lovable:sync --debug           # Show detailed automation logs
/lovable:sync --force-rescan    # Ignore cached results, rescan everything
/lovable:sync --refresh-map     # Regenerate Project Structure Map
```

---

## Instructions

### Step 1: Parse Command Flags

Determine agent mode from user flags:

```
Flags provided → Agent mode:

(no flags)         → interactive (default)
--apply            → auto-apply
--dry-run          → dry-run
--manual           → manual
--debug            → debug
--force-rescan     → invalidate cache, full rescan
--refresh-map      → regenerate Project Structure Map
```

**Multiple flags allowed**: e.g., `--dry-run --debug` combines preview + verbose logging

### Step 2: Invoke Sync-Agent

Delegate to the **sync-agent** with configured mode:

```
Invoke: agents/sync-agent.md

Pass configuration:
- mode: [interactive|auto-apply|dry-run|manual|debug]
- force_rescan: boolean (from --force-rescan flag)

Agent will execute all 5 phases autonomously:
1. Git synchronization
2. Secret discovery
3. State comparison
4. Update proposal
5. Application (if approved)
```

### Step 3: Display Agent Progress

The sync-agent reports progress during execution. Pass through to user:

**Standard output**:
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

[Agent displays diff]

Apply these changes to CLAUDE.md? [y/n]
```

**Debug output** (if `--debug` flag):
```
🐛 DEBUG: Sync Agent Started
Mode: interactive
Flags: debug=true

--- Phase 1: Git Synchronization ---
[0.00s] Running: git fetch origin main
[1.23s] ✅ Fetch completed
[1.24s] Running: git status --porcelain
[1.31s] ✅ No uncommitted changes
[Detailed logging continues...]
```

### Step 4: Handle Agent Results

Agent completes and returns results:

**Success result**:
```javascript
{
  status: "success",
  phase_completed: 5,
  changes_applied: true,
  summary: {
    new_secrets: 1,
    removed_secrets: 1,
    updated_secrets: 1,
    unchanged: 3
  },
  message: "CLAUDE.md updated successfully"
}
```

**Partial success** (dry-run):
```javascript
{
  status: "preview_only",
  phase_completed: 4,  // Stopped before application
  changes_applied: false,
  diff: "...",
  message: "Preview complete. Run without --dry-run to apply."
}
```

**Error result**:
```javascript
{
  status: "error",
  phase_completed: 1,  // Failed at git sync
  error_type: "git_conflict",
  message: "Merge conflicts detected...",
  recovery_instructions: "..."
}
```

### Step 5: Display Final Summary

Show agent's final output to user:

**Success**:
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

**Auto-apply mode**:
```
✅ Auto-sync completed

Updated CLAUDE.md with latest project state.

Changes: +1 secret, -1 secret, ~1 status change

Committed and ready to push.
```

**Dry-run mode**:
```
🔍 DRY RUN - No changes will be made

[Full diff displayed by agent]

To apply these changes:
- Run: /lovable:sync --apply (auto-apply)
- Run: /lovable:sync (interactive, asks confirmation)
```

**Error**:
```
❌ Sync failed: [error from agent]

[Agent's recovery instructions]

For help: /help or consult SKILL.md
```

---

## Agent Delegation Benefits

**Why this command delegates to sync-agent**:
- ✅ **Independent context**: Sync operations don't pollute main coding conversation
- ✅ **Parallel execution**: User can continue working while sync runs
- ✅ **Complex logic isolated**: Agent handles all 5 phases autonomously
- ✅ **Reusability**: Same agent can be invoked by other commands/hooks
- ✅ **Better error handling**: Centralized in agent
- ✅ **Cleaner command**: Command focuses on UX, agent on logic

**Command responsibilities**:
- Parse flags
- Configure agent mode
- Display agent progress (pass-through)
- Show final summary

**Agent responsibilities** (see `agents/sync-agent.md`):
- All 5 synchronization phases
- Git operations and conflict handling
- Secret discovery (codebase + browser + .env)
- State comparison and diff generation
- CLAUDE.md updates with preservation
- Progress reporting
- Error recovery

---

## Common Use Cases

| Scenario | Command | Result |
|----------|---------|--------|
| Check what changed | `/lovable:sync --dry-run` | Preview changes without applying |
| Team added secrets | `/lovable:sync` | Interactive sync, shows diff, asks confirmation |
| Quick auto-update | `/lovable:sync --apply` | Apply changes automatically |
| Browser automation unavailable | `/lovable:sync --manual` | Manual mode with user input |
| Debugging sync issues | `/lovable:sync --debug` | Verbose logging throughout |
| Fresh scan after changes | `/lovable:sync --force-rescan` | Ignore cache, rescan everything |

---

## Integration with Other Commands

**Works with:**
- `/lovable:init` - Use sync to refresh after init
- `/lovable:deploy-edge` - Sync before deployment to verify secrets
- `/lovable:apply-migration` - Sync to check DB state
- `/lovable:yolo` - Sync can run before yolo deployments

**Can be invoked by:**
- Yolo mode (before deployment, if sync_before_deploy enabled)
- Auto-sync hook (future feature)
- Other agents (as part of larger workflows)

---

## Error Handling

All error scenarios are handled by the sync-agent. The command simply displays agent errors and recovery instructions.

**Common agent errors**:
- Git conflicts → Agent aborts, guides user to resolve manually
- Browser automation fails → Agent falls back to manual mode
- CLAUDE.md parse errors → Agent warns, attempts best-effort update
- Network errors → Agent retries with backoff, then fails gracefully
- File write errors → Agent aborts, preserves changes for user to copy

**See `agents/sync-agent.md`** for complete error handling documentation.

---

## Success Criteria

Sync is successful if:
1. ✅ Agent completes all applicable phases
2. ✅ CLAUDE.md updated (or preview shown in dry-run)
3. ✅ User informed of results
4. ✅ Next steps provided

Agent guarantees:
- Never loses user data
- Preserves all customizations
- Clear error messages
- Actionable recovery instructions

---

## Manual Sync Mode

If `--manual` flag or browser automation unavailable, agent prompts:

```
📋 MANUAL SYNC MODE

Browser automation unavailable. Please provide current information from Lovable:

1. Current secrets in Cloud → Secrets:
   (Enter comma-separated secret names, or paste the list)
   > RESEND_API_KEY, STRIPE_SECRET_KEY, OPENAI_API_KEY

2. Which secrets are configured (✅) vs not configured (⚠️)?
   (Mark as: RESEND_API_KEY✅, STRIPE_SECRET_KEY⚠️, ...)
   > RESEND_API_KEY✅, STRIPE_SECRET_KEY⚠️, OPENAI_API_KEY✅

3. Any other changes or notes:
   (Describe what changed since last sync)
   > Added Stripe for payments

Agent will compare with CLAUDE.md and update as needed.
```

---

*This command provides a clean interface to the powerful sync-agent, keeping the main conversation focused while delegating complex synchronization work to an autonomous agent.*
