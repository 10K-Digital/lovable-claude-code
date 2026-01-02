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
   - Scan for secrets using secret-detection skill:
     - `supabase/functions/**/*.ts` for `Deno.env.get("SECRET_NAME")`
     - `.env.example`, `.env.template` for KEY=value patterns
     - Context-based detection (OpenAI, Stripe, Resend, Twilio, etc.)

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

### Question 5: Lovable Project URL
```
What is your Lovable project URL?
(e.g., https://lovable.dev/projects/abc123)

This enables:
✅ Automatic secret extraction from Lovable Cloud
✅ Browser automation features (if you enable yolo mode later)

Leave blank to skip automation features (press Enter):
```

**Action:** If URL provided, store it for use in Question 6.

### Question 6: Secret Detection Method
```
How would you like to detect secrets?

A) Auto-detect from codebase and Lovable Cloud (recommended)
B) Manual entry only

Reply A or B:
```

**If A (Auto-detect):**
1. Scan codebase using patterns from secret-detection skill
2. If Lovable URL provided, attempt browser automation:
   - Navigate to `https://lovable.dev/projects/PROJECT_ID?view=cloud`
   - Use secrets-extraction workflow to get existing secret names
   - Timeout: 30 seconds, fallback gracefully if unavailable
3. Merge findings and present grouped:

```
From codebase (needs setup):
- OPENAI_API_KEY (used in: chat-completion edge function)
- STRIPE_SECRET_KEY (used in: process-payment edge function)

From Lovable Cloud (already configured):
- RESEND_API_KEY (used in: send-email, send-welcome)
- SUPABASE_SERVICE_ROLE_KEY (system)

Any additional secrets to track? (comma-separated, or press Enter to continue)
```

**If B (Manual):**
```
I found these secrets in your code:
- OPENAI_API_KEY (used in: chat-completion edge function)
- STRIPE_SECRET_KEY (used in: process-payment edge function)

Any additional secrets? (comma-separated, or press Enter to continue)
```

### Question 7: Edge Functions Context
```
I found these Edge Functions:
[list]

Any special context I should know?
(e.g., "send-email uses Resend", "payments handles Stripe webhooks")
```

### Question 8: Database Tables (optional)
```
Want me to document main database tables? (yes/no)
```

### Question 9: Special Instructions
```
Any project conventions or special instructions?
```

### Question 10: Yolo Mode (Beta)
```
⚠️ YOLO MODE (BETA) - Browser Automation for Lovable

This feature can automatically submit Lovable prompts using browser automation.

Benefits:
✅ No manual copy-paste needed
✅ Automatic deployment verification
✅ Saves time on every deployment
✅ Auto-run tests after every GitHub push (if enabled)

Risks:
⚠️ Beta feature - may have bugs
⚠️ Requires Chrome extension (Claude in Chrome)
⚠️ Lovable UI changes may break automation
⚠️ Always has manual fallback if automation fails

Enable yolo mode? (yes/no)
Default: no
```

If user answers "yes", ask Question 11. If "no", skip to CLAUDE.md generation.

### Question 11: Yolo Testing and Auto-Run Tests (if yes to Q10)
```
Configure yolo mode:

A) Lovable deployment tests only (current behavior)
B) Lovable tests + auto-run code tests after every push (recommended)
C) No automated testing

Reply A, B, or C:
```

**Options:**
- A: Test Lovable deployments only (Levels 1-3: logs, console errors, functional)
- B: Test Lovable deployments + auto-run project tests after every GitHub push
- C: No automated testing

**Additional detail for B:**
```
Auto-run tests will:
1. Detect test framework (jest, vitest, npm test script)
2. Run tests after each successful git push to main
3. Show results and debug if failures occur
4. Never block deployment if tests fail (manual fallback)

Timeout: 60 seconds per test run
```

### Question 12: Lovable Project URL (if not answered in Q5)
```
What is your Lovable project URL?
(e.g., https://lovable.dev/projects/abc123)

This is required for browser automation.
```

**Note:** Only ask if user skipped Q5 and is enabling yolo mode.

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
- **Lovable Project URL**: [if provided]
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

| Name | Purpose | Status | Used In |
|------|---------|--------|---------|
| OPENAI_API_KEY | OpenAI chat completions | ⚠️ Not configured | chat-completion |
| STRIPE_SECRET_KEY | Stripe payments | ⚠️ Not configured | process-payment |
| RESEND_API_KEY | Email sending via Resend | ✅ In Lovable Cloud | send-email, send-welcome |
| SUPABASE_SERVICE_ROLE_KEY | Supabase admin access | ✅ In Lovable Cloud | (system) |

**Legend:**
- ✅ In Lovable Cloud - Secret already configured
- ⚠️ Not configured - Needs setup in Cloud → Secrets

**To add secrets:**
1. Go to Cloud → Secrets in Lovable
2. Click "Add secret"
3. Enter name and value
4. Run: `"Redeploy edge functions to pick up new secrets"`

## Edge Functions

| Function | Purpose | Required Secrets | Status |
|----------|---------|------------------|--------|
| send-email | Send transactional emails | RESEND_API_KEY | ✅ Secret configured |
| process-payment | Handle Stripe webhooks | STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET | ⚠️ Missing STRIPE_WEBHOOK_SECRET |
| chat-completion | AI chat completions | OPENAI_API_KEY | ⚠️ Secret not configured |

**Warning:** Functions marked with ⚠️ will fail until secrets are added in Cloud → Secrets.

## Database Tables
[if provided]

## Project Conventions
[user input]

## Yolo Mode Configuration (Beta)
[ONLY include if user enabled yolo mode]

> ⚠️ Beta feature - uses browser automation to auto-submit Lovable prompts

- **Status**: [on/off based on Q10 answer]
- **Deployment Testing**: [on/off based on Q11 answer, default: on]
- **Auto-run Tests**: [on/off - run tests after every git push]
- **Debug Mode**: off
- **Last Updated**: [current timestamp]
- **Operations Covered**:
  - Edge function deployment
  - Migration application
  - Automated testing after code push

**Configure:** Run `/lovable:yolo on/off [--testing|--no-testing] [--debug]`

**How it works:**
- When yolo mode is on, I'll automatically navigate to Lovable and submit prompts
- Deployment testing verifies deployments (3 levels: basic, console errors, functional)
- Auto-run tests execute your project's test suite after every git push
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
