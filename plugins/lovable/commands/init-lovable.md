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

### Question 8.5: Project Structure Map
```
Would you like me to generate a Project Structure Map?

This map helps me navigate your codebase faster by documenting:
- Directory structure and purposes
- Key files and their roles
- Component organization patterns

Generate map? (yes/no)
Default: yes (recommended)
```

**If yes:** Use the codebase-map reference (`skills/lovable/references/codebase-map.md`) to:
1. Scan directory structure (src/, supabase/, etc.)
2. Count components, pages, hooks, functions
3. Detect component organization pattern (flat, feature-based, atomic)
4. Identify key files (App.tsx, utils.ts, supabase client)
5. Detect state management pattern
6. Generate the map section for CLAUDE.md

**If no:** Skip map generation, don't include the Project Structure Map section in CLAUDE.md.

### Question 9: Auto-Push to GitHub
```
⚡ AUTO-PUSH TO GITHUB

When enabled, Claude will automatically commit and push your changes to GitHub
after every successful task completion - no manual git commands needed!

Benefits:
✅ Instant sync to GitHub → Lovable
✅ No more forgetting to commit/push changes
✅ Seamless workflow from code → production
✅ Required for yolo mode automation

How it works:
1. You ask Claude to make changes
2. Claude completes the task successfully
3. Claude automatically commits with descriptive message
4. Claude pushes to main branch on GitHub
5. GitHub syncs to Lovable (frontend changes instantly)

Enable auto-push to GitHub? (yes/no)
Default: yes (recommended)
```

**Note:** This setting is independent of yolo mode, but yolo mode requires auto-push to be enabled.

### Question 10: Special Instructions
```
Any project conventions or special instructions?
```

### Question 11: Yolo Mode (Beta)

**First, check if Lovable MCP tools are available.** Then show the appropriate prompt:

**If Lovable MCP is connected:**
```
⚠️ YOLO MODE (BETA) - Automated Lovable Deployments

Lovable MCP is connected! Yolo mode can submit deployment prompts
directly via API - no browser automation needed.

Benefits:
✅ No manual copy-paste needed
✅ Fast API-based deployments (3-5x faster than browser)
✅ Automatic deployment verification
✅ No Chrome extension required
✅ Auto-run tests after every GitHub push (if enabled)

Risks:
⚠️ Beta feature - may have bugs
⚠️ Uses Lovable credits for each deployment
⚠️ Always has manual fallback if automation fails

Enable yolo mode with MCP? (yes/no)
Default: no
```

**If Lovable MCP is NOT connected:**
```
⚠️ YOLO MODE (BETA) - Automated Lovable Deployments

This feature can automatically submit Lovable prompts.

Benefits:
✅ No manual copy-paste needed
✅ Automatic deployment verification
✅ Saves time on every deployment
✅ Auto-run tests after every GitHub push (if enabled)

Deployment methods available:
⚡ Lovable MCP (recommended, faster) - Setup later with /lovable:connect-mcp
🌐 Browser automation (fallback) - Requires Chrome extension

Risks:
⚠️ Beta feature - may have bugs
⚠️ Browser automation requires Chrome extension (Claude in Chrome)
⚠️ Always has manual fallback if automation fails

Enable yolo mode? (yes/no)
Default: no
```

**Important:** If user wants to enable yolo mode but answered "no" to auto-push (Question 9):
```
⚠️ Yolo mode requires auto-push to be enabled.

Auto-push is currently disabled. To enable yolo mode, auto-push must be turned on.

Enable auto-push now? (yes/no)
```

If user says "yes", enable both yolo mode and auto-push. If "no", disable yolo mode and continue.

If user answers "yes" to yolo mode (and auto-push is already enabled), ask Question 12. If "no" to yolo mode, skip to CLAUDE.md generation.

### Question 12: Yolo Testing and Auto-Run Tests (if yes to Q11)
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

### Question 13: Lovable Project URL (if not answered in Q5)
```
What is your Lovable project URL?
(e.g., https://lovable.dev/projects/abc123)

This is required for browser automation.
```

**Note:** Only ask if user skipped Q5 and is enabling yolo mode (Q11).

4. **Generate CLAUDE.md** in project root with gathered info.

   - **CRITICAL:** Include the "🚨 IMPORTANT: Always Commit and Push to GitHub" section at the top (after Project Overview)
     - This reminds Claude to ALWAYS commit and push changes so they sync from GitHub to Lovable
     - Without this instruction, Claude might make changes that don't get synced
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

## Auto-Push Configuration

- **Auto-Push to GitHub**: [on/off based on Q9 answer, default: on]
- **Last Updated**: [current timestamp]

**How auto-push works:**
When enabled, I'll automatically commit and push changes after each successful task:
1. You ask me to make changes
2. I complete the task successfully
3. I automatically commit with a descriptive message
4. I push to main branch on GitHub
5. GitHub syncs to Lovable (frontend changes appear instantly)

**Note:** Auto-push works independently of yolo mode, but yolo mode requires it to be enabled.

**To disable:** Run `/lovable:auto-push off` (or edit this file directly)

## Yolo Mode Configuration (Beta)
[ONLY include if user enabled yolo mode]

> ⚠️ Beta feature - auto-submits Lovable prompts via MCP or browser automation
> ⚠️ Requires auto-push to be enabled

- **Status**: [on/off based on Q11 answer]
- **Deployment Method**: [mcp if MCP was connected at init time; auto otherwise]
- **Deployment Testing**: [on/off based on Q12 answer, default: on]
- **Auto-run Tests**: [on/off - run tests after every git push]
- **Debug Mode**: off
- **Last Updated**: [current timestamp]
- **Operations Covered**:
  - Automatic deployment detection after git push
  - Edge function deployment
  - Migration application
  - Automated testing after code push

**Configure:** Run `/lovable:yolo on/off [--mcp|--browser|--auto] [--testing|--no-testing] [--debug]`
**Connect MCP:** Run `/lovable:connect-mcp` for faster API-based automation

**How yolo mode works:**
- **Deployment Method: auto** - Tries Lovable MCP first, falls back to browser automation
- When yolo mode is on, after auto-push completes, I'll automatically submit deployment prompts
- Deployment testing verifies deployments (3 levels: basic, console errors, functional)
- Auto-run tests execute your project's test suite after every git push
- Always has manual fallback if automation fails

**Workflow with both enabled:**
1. You ask me to make changes
2. I complete the task successfully
3. Auto-push: I commit and push to GitHub
4. Yolo mode: I detect backend changes and auto-deploy to Lovable (via MCP or browser)
5. Done - zero manual commands needed!

## Quick Prompts
| Task | Prompt |
|------|--------|
| Deploy functions | "Deploy all edge functions" |
| Apply migrations | "Apply pending Supabase migrations" |
| Check logs | "Show logs for [name] edge function" |

---
*Generated by /lovable:init on [date]*
```
