---
description: Check if GitHub changes have synced with Lovable. Shows pending changes and required Lovable prompts.
---

# Check Lovable Sync Status

Verify GitHub ↔ Lovable sync status and list pending actions.

## Instructions

1. **Check current branch**:
   - If NOT `main`: warn that only `main` syncs
   - Show how to switch or merge

2. **Check for uncommitted changes**:
   - List modified files
   - Remind to commit

3. **Check for unpushed commits**:
   - Show commits ahead of origin/main
   - Remind to push

4. **Categorize pending changes**:

### Auto-sync (frontend)
Files that will sync automatically:
- `src/**/*`
- Config files
- `package.json`

### Needs Lovable deployment
Files that need additional action:
- `supabase/functions/**/*` → deploy prompt
- `supabase/migrations/**/*` → apply prompt

5. **Generate action checklist**:

```
## Next Steps:
1. [ ] Commit: `git add . && git commit -m "message"`
2. [ ] Push: `git push origin main`
3. [ ] Wait 1-2 min for Lovable sync
4. [ ] Run in Lovable: [prompts]
5. [ ] Verify at: [production URL]
```

## Output Format

```
## Sync Status

**Branch**: main ✅
**Uncommitted changes**: None ✅
**Unpushed commits**: 2 commits ⚠️

### Will Auto-Sync:
- src/components/Button.tsx (modified)
- src/pages/Dashboard.tsx (new)

### Needs Lovable Deployment:
- supabase/functions/send-email/index.ts
  → "Deploy the send-email edge function"

- supabase/migrations/20250101_add_table.sql
  → "Apply pending Supabase migrations"

## Action Checklist:
1. [x] Commit changes
2. [ ] Push: `git push origin main`
3. [ ] Wait 1-2 min
4. [ ] Lovable prompts:
   - "Deploy the send-email edge function"
   - "Apply pending Supabase migrations"
5. [ ] Verify at: https://my-app.lovable.app
```

## Branch Warning

If not on main:
```
⚠️ **Wrong branch**: You're on `feature-xyz`

Only `main` syncs with Lovable. Options:
1. Switch to main: `git checkout main`
2. Merge changes: `git checkout main && git merge feature-xyz`
3. Create PR and merge on GitHub
```
