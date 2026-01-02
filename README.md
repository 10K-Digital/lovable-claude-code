# Lovable Integration Plugin for Claude Code

Ever wanted to use Claude Code to edit your [Lovable.dev](https://lovable.dev)  projects and save on credits, but found it hard to work with Lovable's two-way GitHub sync? This plugin makes it easy!

Now you can edit Lovable's projects right from your IDE while getting exact prompts to use in Lovable for backend deployment operations. You can go yolo and use browser automation to even prompt Lovable for you!

Use your Claude subscrption tokens to make the heavy lifting. Claude will handle all the complex changes in your project and sync them back to GitHub. Then it will tell you how to prompt for any additional deployments to Lovable Cloud.

Use Claude Code for enhanced control over your codebase, usage of MCPs, agents, plug-ins and other advanced Claude Code features that you can't find in Lovable.

Then let Claude Code sync everything back to GitHub and Lovable, while getting exact prompts for backend operations, and even prompts them for you using browser automation.

## Why This Plugin?

Lovable is great, but lacks refined control over the projects. Additionaly, it often requires additional credits and subcription upgrades once your project grows.

You can still use Lovable's amazing features and cloud, whilke taking advantages of Claude Code's advanced features, while using your Claude Subscription's tokens for major projects changes. 

Lovable uses two-way GitHub sync, but backend operations (Edge Functions, migrations, RLS policies) require prompts in Lovable's interface. This plugin:

- ✅ Tells you what syncs automatically vs. needs Lovable prompts
- ✅ Generates exact Lovable prompts for backend operations when needed
- ✅ Uses browser automation to prompt Lovable for you and perform tests in yolo mode (beta)
- ✅ Tracks sync status between GitHub and Lovable
- ✅ Initializes project context for Claude Code

You will only prompt Lovable if your changes need extra deployment tasks to Lovable Cloud, such as database migrations and Edge Functions. When that is the case, Claude Code will inform you and generate the exact prompt for Lovable, saving you time, money, and ensuring accuracy.

You can even turn yolo mode on. Im this case, Claude Code will use its native browser automatiom to navigate to your Lovable project and prompt it for you whenever necessary! It can even test the project to ensure everything is working correctly.



## Installation

### Frist of all, make sure you match all requirements

- Your Lovable project has GitHub sync enabled. [read more](https://docs.lovable.dev/integrations/github#about-github)
- Claude Code is configured to use your Lovable project's GitHub repository
- Claude Code with Chrome is setup in your environment with [Claude in Chrome extension](https://chrome.google.com/webstore/detail/claude/pebppomjfocnoigkeepgbmcifnnlndla) installed in your browser. [read more](https://docs.claude.com/claude/code-intelligence/browser-automation) (for yolo mode)
 - Make sure your browser is logged into your Lovable account with access to your project
 - Make sure Claude in Chrome extension permissions allows access to all Lovable URLs of your project.

### Via Claude Code Plugin Marketplace (Recommended)

Open Claude Code and type the following instructions.

```bash
# Add the marketplace
/plugin marketplace add 10kdigital/lovable-claude-code

# Install the plugin
/plugin install lovable-claude-code@10-kdigital
```

### Local Installation

1. Clone or download this repo
2. Copy to your project or Claude Code plugins directory:
```bash
# Project-level (recommended)
cp -r lovable-plugin/.claude-plugin your-project/.claude-plugin
cp -r lovable-plugin/commands your-project/.claude/commands
cp -r lovable-plugin/skills your-project/.claude/skills

# Or user-level
cp -r lovable-plugin ~/.claude/plugins/lovable-integration
```

3. Run `/lovable:init` to setup your integration

## Commands

All plugin commands use the `/lovable:` prefix to avoid conflicts with other plugins.

| Command | Description |
|---------|-------------|
| `/lovable:init` | Interactive setup - scans repo, asks questions, generates CLAUDE.md |
| `/lovable:deploy-edge` | Check Edge Function changes, get deployment prompts or auto-deploy |
| `/lovable:apply-migration` | Check pending migrations, get prompts or auto-apply |
| `/lovable:prompt` | Generate any Lovable prompt on demand |
| `/lovable:sync-status` | Check GitHub ↔ Lovable sync status |
| `/lovable:yolo` [on\|off] [options] | Configure yolo mode for automated deployments |

### Yolo Mode Options

```bash
/lovable:yolo                  # Show current status
/lovable:yolo on               # Enable with testing (default)
/lovable:yolo on --no-testing  # Enable without verification tests
/lovable:yolo on --debug       # Enable with verbose browser automation logs
/lovable:yolo off              # Disable automation
```

**What is Yolo Mode?** (Beta)
- Automatically navigates to Lovable and submits deployment prompts
- Runs 3 levels of verification tests (basic, console errors, functional)
- Requires [Claude in Chrome extension](https://chrome.google.com/webstore/detail/claude/pebppomjfocnoigkeepgbmcifnnlndla)
- Always has manual fallback if automation fails

## Quick Start

1. Open your Lovable project in Claude Code
2. Run `/lovable:init`
3. Answer the setup questions (including yolo mode preferences)
4. Start coding!

**Without yolo mode:** When you make backend changes, Claude will tell you:
```
📋 **LOVABLE PROMPT:**
> "Deploy the send-email edge function"
```
Just copy-paste into Lovable.

**With yolo mode:** Claude automatically deploys for you:
```
🤖 Yolo mode: Deploying send-email edge function
✅ Deployment complete and verified!
```

## What Syncs Automatically

| Change | Auto-Sync? | Action Needed |
|--------|------------|---------------|
| React components | ✅ Yes | Push to `main` |
| Styling/CSS | ✅ Yes | Push to `main` |
| Edge Function code | ⚠️ Code only | + Lovable deploy prompt |
| Migration files | ⚠️ File only | + Lovable apply prompt |
| New tables | ❌ No | Lovable prompt only |
| RLS policies | ❌ No | Lovable prompt only |
| Secrets | ❌ No | Cloud UI only |

## Workflow Examples

### Manual Workflow (Yolo Mode OFF)

```bash
# 1. Make changes with Claude Code
> Add a new edge function to send welcome emails

# Claude creates supabase/functions/send-welcome/index.ts

# 2. Claude tells you:
📋 **LOVABLE PROMPT:**
> "Deploy the send-welcome edge function"

⚠️ **Secret required**: RESEND_API_KEY
Add in Cloud → Secrets before deploying

# 3. Push to GitHub
git add . && git commit -m "Add welcome email" && git push

# 4. Copy-paste prompt into Lovable
# 5. Done!
```

### Automated Workflow (Yolo Mode ON)

```bash
# 1. Enable yolo mode
> /lovable:yolo on

# 2. Make changes with Claude Code
> Add a new edge function to send welcome emails

# Claude creates supabase/functions/send-welcome/index.ts

# 3. Push to GitHub
git add . && git commit -m "Add welcome email" && git push

# 4. Deploy automatically
> /lovable:deploy-edge

🤖 Yolo mode: Deploying send-welcome edge function
⏳ Navigating to Lovable...
✅ Submitted prompt
✅ Deployment confirmed
✅ All tests passed

## Deployment Summary
Status: ✅ Success
Duration: 38 seconds
Tests: All passed

# 5. Done! No manual steps needed
```

## Files Generated

After `/lovable:init`:

```
your-project/
├── CLAUDE.md          # Project context (edit this!)
└── ... your code
```

## Configuration

Edit `CLAUDE.md` to customize:
- Production URL
- List of secrets
- Database tables
- Project conventions

## Requirements

- Claude Code
- Lovable.dev project with GitHub connected
- GitHub sync on `main` branch

## License

MIT

## Contributing

Issues and PRs welcome at [github.com/felipematos/claude-code-lovable-plugin](https://github.com/felipematos/claude-code-lovable-plugin)
