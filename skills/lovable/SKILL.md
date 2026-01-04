---
name: lovable
description: |
  Integration skill for Lovable.dev projects. Activates when working with:
  - Lovable.dev projects with GitHub sync
  - Supabase Edge Functions that need deployment
  - Database migrations for Lovable Cloud
  - Projects with supabase/ directory structure
  - Any mention of "Lovable", "deploy edge function", "apply migration"
  
  Provides exact Lovable prompts for backend operations that can't be done via GitHub alone.
---

# Lovable Integration Skill

This skill enables Claude Code to work effectively with Lovable.dev projects while respecting Lovable's deployment requirements.

## When to Use This Skill

Activate when:
- User mentions "Lovable" or "lovable.dev"
- Project has `supabase/` directory with Edge Functions
- User asks to deploy edge functions
- User creates database migrations
- User asks about Lovable Cloud or backend deployment
- Project appears to be a Lovable project (React + Supabase structure)

## Core Concept

Lovable uses **two-way GitHub sync** on the `main` branch only:
- Frontend code syncs automatically
- Backend operations (Edge Functions, migrations, RLS) require Lovable prompts

## What Syncs Automatically (GitHub → Lovable)

✅ Edit freely and push to `main`:
- `src/` - All React components, pages, hooks, utils
- `public/` - Static assets
- Config files - vite.config.ts, tailwind.config.js, tsconfig.json
- `package.json` - Dependencies
- `supabase/functions/*/index.ts` - Edge Function **code** (not deployment)
- `supabase/migrations/*.sql` - Migration **files** (not application)

## What Requires Lovable Deployment

⚠️ After editing, provide Lovable prompt:

| Change Type | Lovable Prompt |
|-------------|----------------|
| Edge Function code | `"Deploy the [name] edge function"` |
| All Edge Functions | `"Deploy all edge functions"` |
| New migration file | `"Apply pending Supabase migrations"` |
| New table needed | `"Create a [name] table with columns: [list]"` |
| RLS policy | `"Enable RLS on [table] allowing [who] to [what]"` |
| Storage bucket | `"Create a [public/private] bucket called [name]"` |
| Secret/env var | Manual: Cloud → Secrets → Add |

## Response Format

When backend deployment is needed, always output:

```
📋 **LOVABLE PROMPT:**
> "[exact prompt to copy-paste]"
```

For destructive operations, add:
```
⚠️ **Warning**: [explanation of risk]
```

## File Structure Reference

```
project/
├── src/                          # ✅ Safe - auto-syncs
│   ├── components/
│   ├── pages/
│   ├── hooks/
│   ├── lib/
│   └── integrations/supabase/
│       ├── client.ts             # ⚠️ Has Supabase URLs
│       └── types.ts
├── supabase/
│   ├── functions/                # ✅ Edit code, ⚠️ needs deploy
│   │   └── [function-name]/
│   │       └── index.ts
│   ├── migrations/               # ✅ Create files, ⚠️ needs apply
│   │   └── YYYYMMDDHHMMSS_*.sql
│   └── config.toml               # ⚠️ Lovable Cloud manages
├── .env                          # Local only - Lovable ignores
└── CLAUDE.md                     # Project context
```

## Backend Types

### Lovable Cloud
- Backend managed entirely by Lovable
- No Supabase dashboard access
- All operations via Lovable prompts
- Secrets in Cloud → Secrets UI

### Own Supabase
- Direct Supabase dashboard access
- Can use Supabase CLI: `supabase functions deploy`
- More flexibility but manual setup

## Quick Prompts Reference

### Edge Functions
```
"Deploy all edge functions"
"Deploy the send-email edge function"
"Create an edge function called [name] that [description]"
"Show logs for [name] edge function"
"The [name] edge function returns [error]. Fix it"
```

### Database
```
"Create a [name] table with columns: id (uuid), name (text), created_at (timestamp)"
"Add a [column] column of type [type] to [table]"
"Add foreign key from [table1].[col] to [table2].id"
"Apply pending Supabase migrations"
```

### RLS Policies
```
"Enable RLS on [table]"
"Add RLS policy on [table] allowing authenticated users to read all rows"
"Add RLS policy on [table] allowing users to only access their own rows"
```

### Storage
```
"Create a public storage bucket called [name]"
"Create a private storage bucket called [name]"
"Allow authenticated users to upload to [bucket]"
```

### Auth
```
"Enable Google authentication"
"Enable GitHub authentication"
"When user signs up, create row in profiles table"
```

## Branch Rules

- **Only `main` syncs** with Lovable
- Feature branches don't deploy until merged
- Lovable syncs within 1-2 minutes of push

## Auto-Push to GitHub (Independent Feature)

When `Auto-Push to GitHub: on` is configured in CLAUDE.md (separate from Yolo Mode):

**Important:** Auto-push is independent of yolo mode:
- ✅ Auto-push can be ON while yolo mode is OFF
- ✅ Auto-push can be ON while yolo mode is ON
- ❌ Auto-push CANNOT be OFF if yolo mode is ON (yolo requires auto-push)

### When to Auto-Push

After **successfully completing a task** where you made code changes:

1. **Check for changes:**
   ```bash
   git status
   ```

2. **If there are changes to commit:**
   - Stage all changes: `git add .`
   - Create descriptive commit message following the project's commit style
   - Commit: `git commit -m "message"`
   - Push to main: `git push origin main`

3. **Commit message format:**
   - Use the project's commit message style (check recent commits with `git log`)
   - Be descriptive about what changed
   - Example: "Add email notifications to send-email edge function"
   - Example: "Update user profile component with avatar upload"
   - Example: "Fix authentication bug in login flow"

### When NOT to Auto-Push

❌ **Skip auto-push if:**
- The task was NOT successful (errors occurred, task incomplete)
- No file changes were made
- User explicitly said not to push
- Currently on a feature branch (not main)
- User is just asking questions or exploring code

### Auto-Push Workflow Example

```
User: "Add email notifications to the send-email function"
     ↓
You: Make the code changes
     ↓
Check: Auto-Push enabled in CLAUDE.md?
     ↓
Yes: Run git commands automatically
     ↓
Output:
"✅ Changes completed and pushed to GitHub!

Committed: Add email notifications to send-email edge function
Pushed to: origin/main

[If yolo mode is also on:]
🤖 Auto-deploy will now trigger to deploy these changes to Lovable..."
```

### Important Notes

- **Always inform the user** when you auto-push
- **Show the commit message** you used
- **Verify git push succeeded** before claiming success
- **Handle errors gracefully** - if push fails, inform user and suggest manual push
- **Check you're on main branch** before pushing
- **Never force push** without explicit user permission

### Safety Checks

Before auto-pushing, verify:

1. ✅ Auto-Push is enabled in CLAUDE.md
2. ✅ Task completed successfully (no errors)
3. ✅ There are actual file changes (`git status` shows changes)
4. ✅ Currently on main branch (`git branch --show-current`)
5. ✅ No merge conflicts or git errors

## Yolo Mode - Automated Deployments (Beta)

When `yolo_mode: on` in CLAUDE.md, deployments are automated via browser automation:

### How It Works

Instead of showing manual prompts, the **yolo skill** (`/skills/yolo/SKILL.md`) takes over:
1. Automatically navigates to Lovable.dev
2. Submits deployment prompts
3. Monitors for success/failure
4. Runs verification tests (if enabled)
5. Reports deployment summary

### When Yolo Mode Activates

- During `/lovable:deploy-edge` command
- During `/lovable:apply-migration` command
- When `yolo_mode: on` in CLAUDE.md

### Configure Yolo Mode

```
/lovable:yolo on               # Enable with testing
/lovable:yolo on --no-testing  # Enable without testing
/lovable:yolo on --debug       # Enable with verbose logs
/lovable:yolo off              # Disable
```

### Beta Status

⚠️ Yolo mode is in beta:
- Requires Claude in Chrome extension
- May have bugs or UI compatibility issues
- Always has manual fallback
- See `/skills/yolo/SKILL.md` for details

## Debugging Checklist

1. **Frontend not updating?**
   - On `main` branch?
   - Changes pushed?
   - Wait 1-2 min

2. **Edge Function not working?**
   - Deployed via Lovable (or yolo mode)?
   - Secrets set in Cloud UI?
   - Check logs in Lovable

3. **Database query failing?**
   - Migration applied (via Lovable or yolo mode)?
   - RLS policies correct?
   - Table exists?

4. **Yolo mode not working?**
   - Check `yolo_mode: on` in CLAUDE.md
   - Chrome extension installed?
   - Logged into Lovable?
   - See yolo skill for troubleshooting
