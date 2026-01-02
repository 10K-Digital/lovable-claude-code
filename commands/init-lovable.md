---
description: Initialize Lovable project context. Scans repo, asks questions, generates CLAUDE.md with project-specific configuration.
---

# Initialize Lovable Project

Set up Claude Code to work with this Lovable.dev project.

## Instructions

1. **Read the lovable skill** for full context on integration patterns.

2. **Scan the repository** to understand structure:
   - Check for `supabase/` folder
   - List Edge Functions in `supabase/functions/`
   - List migrations in `supabase/migrations/`
   - Check `src/integrations/supabase/client.ts` for config
   - Read `package.json` for project name
   - Look for `.env.example` to identify secrets

3. **Ask questions ONE at a time** using the ask_user tool:

### Question 1: Backend Type
```
Is your Lovable project using:
A) Lovable Cloud (backend managed by Lovable - no Supabase dashboard access)
B) Your own Supabase project (direct dashboard access)

Reply A or B:
```

### Question 2: Production URL
```
What is your Lovable production URL?
(e.g., https://my-app.lovable.app or custom domain)
```

### Question 3: GitHub Repository
```
What is the GitHub repository URL?
```

### Question 4: Supabase Project (if B)
```
What is your Supabase project reference ID?
(Supabase Dashboard → Project Settings → General)
```

### Question 5: Secrets
```
I found references to these secrets in the code:
[list detected]

Any additional secrets? (names only, not values)
```

### Question 6: Edge Functions Context
```
I found these Edge Functions:
[list]

Any special context I should know?
(e.g., "send-email uses Resend", "payments handles Stripe webhooks")
```

### Question 7: Database Tables (optional)
```
Want me to document main database tables? (yes/no)
```

### Question 8: Special Instructions
```
Any project conventions or special instructions?
```

### Question 9: Yolo Mode (Beta)
```
⚠️ YOLO MODE (BETA) - Browser Automation for Lovable

This feature can automatically submit Lovable prompts using browser automation.

Benefits:
✅ No manual copy-paste needed
✅ Automatic deployment verification
✅ Saves time on every deployment

Risks:
⚠️ Beta feature - may have bugs
⚠️ Requires Chrome extension (Claude in Chrome)
⚠️ Lovable UI changes may break automation
⚠️ Always has manual fallback if automation fails

Enable yolo mode? (yes/no)
Default: no
```

If user answers "yes", ask Question 10. If "no", skip to CLAUDE.md generation.

### Question 10: Yolo Testing (if yes to Q9)
```
Enable automated testing after deployments?

Testing levels:
- Level 1: Basic verification (check logs via Lovable)
- Level 2: Console error checking (monitor production URL)
- Level 3: Functional testing (test endpoints/queries)

This adds 1-3 minutes per deployment but catches issues early.

Enable testing? (yes/no)
Default: yes
```

### Question 11: Lovable Project URL (if yes to Q9)
```
What is your Lovable project URL?
(e.g., https://lovable.dev/projects/abc123)

This is required for browser automation.
```

4. **Generate CLAUDE.md** in project root with gathered info.

   - Include yolo mode configuration if enabled
   - Set yolo_mode, yolo_testing, yolo_debug based on answers
   - Include lovable_url if provided

5. **Confirm setup** with summary.

## CLAUDE.md Template

```markdown
# CLAUDE.md - Lovable Project Context

## Project Overview
- **Name**: [from package.json]
- **Production URL**: [user input]
- **Lovable Project URL**: [if yolo mode enabled]
- **GitHub**: [user input]
- **Backend**: [Lovable Cloud / Own Supabase]

## Workflow Rules

### ✅ Safe to edit and push to `main`:
- All `src/` files
- Config files
- Edge Function code (deployment needs Lovable)

### ⚠️ Requires Lovable prompt after edit:
- Edge Functions → `"Deploy the [name] edge function"`
- Migrations → `"Apply pending migrations"`

### ❌ Must use Lovable:
- Create tables, RLS, storage buckets
- Add secrets (Cloud UI)

## Secrets
[list]

## Edge Functions
| Function | Purpose | Secrets |
|----------|---------|---------|
[table]

## Database Tables
[if provided]

## Project Conventions
[user input]

## Yolo Mode Configuration (Beta)
[ONLY include if user enabled yolo mode]

> ⚠️ Beta feature - uses browser automation to auto-submit Lovable prompts

- **Status**: [on/off based on Q9 answer]
- **Testing**: [on/off based on Q10 answer, default: on]
- **Debug Mode**: off
- **Last Updated**: [current timestamp]
- **Operations Covered**:
  - Edge function deployment
  - Migration application

**Configure:** Run `/lovable:yolo on/off [--testing|--no-testing] [--debug]`

**How it works:**
- When yolo mode is on, I'll automatically navigate to Lovable and submit prompts
- Testing verifies deployments (3 levels: basic, console errors, functional)
- Debug mode shows detailed browser automation logs
- Always has manual fallback if automation fails

## Quick Prompts
| Task | Prompt |
|------|--------|
| Deploy functions | "Deploy all edge functions" |
| Apply migrations | "Apply pending Supabase migrations" |
| Check logs | "Show logs for [name] edge function" |

---
*Generated by /lovable:init on [date]*
```
