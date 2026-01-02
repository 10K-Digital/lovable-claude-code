# 🚀 Lovable + Claude Code = Superpowers

## **Edit Lovable Projects 10x Faster—Without Leaving Your IDE**

Stop copy-pasting between Lovable and Claude. Stop wrestling with two-way sync. Stop burning through API credits for simple changes.

**The Lovable Claude Code plugin brings the power of your IDE directly to your Lovable projects.** Edit code with AI assistance, deploy automatically, and let Claude Code handle all the complexity of syncing with Lovable Cloud.

### **What You Get:**

✨ **Edit Lovable projects right in your IDE** with all of Claude Code's power
🤖 **Automatic deployments** (yolo mode) - no manual copy-paste needed
💰 **Save credits** by using your Claude subscription for heavy lifting
🔄 **Zero friction syncing** between your code, GitHub, and Lovable Cloud
🛡️ **Automatic secret detection** - never forget a required API key
⚡ **Instant setup** - generates project context automatically
✅ **Verification built-in** - tests run after every deployment

---

## **The Problem You're Solving**

Working with Lovable is amazing... until it's not:

- 😤 **Context switching pain** - Lovable UI for backend, IDE for frontend, back and forth endlessly
- 💸 **Credit drain** - Lovable charges for what Claude Code can do cheaper (via your subscription)
- 🤷 **Sync confusion** - "What syncs automatically? What needs manual deployment?" Constantly unsure
- ⏱️ **Manual workflows** - Copy prompt → Paste into Lovable → Wait for response → Repeat
- 🔑 **Secret chaos** - Tracking which secrets each function needs, which ones you set up, which ones are missing
- 🐛 **Deploy blind** - No automated tests after deployment. Hope it works!

**This plugin eliminates every single one of these friction points.**

---

## **How It Works (In 90 Seconds)**

### **1️⃣ One-Time Setup**
```bash
/lovable:init
```
Claude Code scans your project, asks a few questions, and generates `CLAUDE.md` with all the context it needs.

### **2️⃣ Make Your Changes**
Edit code in your IDE like normal. Claude Code with AI handles the complex stuff.

### **3️⃣ Automatic Everything**
```bash
/lovable:deploy-edge    # Deploy to Lovable
/lovable:sync           # Keep secrets/config in sync
```

That's it. No manual prompts. No context switching. No forgotten steps.

---

## **Real Workflows**

### **🎯 Manual Mode (Full Control)**
```
You: "Add email notifications to the send-email function"
     ↓
Claude Code: Creates the code
             ↓
Shows you: "Deploy with this prompt: 'Deploy the send-email edge function'"
           Plus: "⚠️ Needs RESEND_API_KEY"
           ↓
You: Copy-paste prompt to Lovable (takes 10 seconds)
Result: ✅ Function deployed, tests pass, you're informed
```

### **🚀 Yolo Mode (Full Automation)**
```
You: "Add email notifications"
     ↓
Claude Code: Creates the code, detects needed secrets
             ↓
You: /lovable:deploy-edge
     ↓
Claude: 🤖 Automatically navigates to Lovable
        ✅ Submits deployment
        ✅ Runs verification tests
        ✅ Confirms success

Done. Zero manual work.
```

---

## **Key Features That Save You Hours**

### 🔐 **Smart Secret Detection**
Claude Code automatically finds every secret your functions need—by scanning your code. No more "why is this function failing??"—we tell you upfront: "You need STRIPE_WEBHOOK_SECRET."

### 🔄 **Automatic Sync Command**
Team member added a secret in Lovable Cloud? Run `/lovable:sync` and it updates your project config. No more getting out of sync.

### ⚡ **Auto-Run Tests**
Enable tests to run automatically after every deployment. Catch issues in seconds, not after users report bugs.

### 📊 **Secret Status Dashboard**
CLAUDE.md shows exactly which secrets are configured (✅) and which need setup (⚠️). One glance tells you if you're ready to deploy.

### 🎯 **Context Everything**
Claude Code knows your production URL, database tables, edge functions, secrets, and conventions. Ask it anything about your project—it already knows.

---

## **Installation (2 Minutes)**

### **Option 1: Via Marketplace (Recommended)**

```bash
# In Claude Code, run:
/plugin marketplace add 10K-Digital/lovable-claude-code

# Install the plugin:
/plugin install lovable@10k-digital
```

💡 **Tip:** Enable auto-updates in Claude Code settings so you always get the latest version automatically.

### **Option 2: Local Installation**

Clone or download this repo, then:
```bash
cp -r lovable-plugin/.claude-plugin your-project/.claude-plugin
cp -r lovable-plugin/commands your-project/.claude/commands
cp -r lovable-plugin/skills your-project/.claude/skills
```

### **Option 3: Requirements Check** ✓

Before you start, make sure you have:
- ✅ Your Lovable project with GitHub sync enabled ([docs](https://docs.lovable.dev/integrations/github#about-github))
- ✅ Claude Code configured with your GitHub repo
- ✅ (Optional) [Claude in Chrome extension](https://chrome.google.com/webstore/detail/claude/pebppomjfocnoigkeepgbmcifnnlndla) for yolo mode

---

## **Your First 5 Minutes**

```bash
# 1. Initialize your project
/lovable:init

# 2. Answer the questions (1 minute)
#    - What's your production URL?
#    - Enable yolo mode? (optional)
#    - etc.

# 3. Start coding!
# Claude Code now knows everything about your project

# 4. When you deploy:
/lovable:deploy-edge
# Get exact prompts or auto-deploy (if yolo enabled)

# 5. Keep in sync:
/lovable:sync
# Updates CLAUDE.md with latest secrets/config
```

---

## **Commands at a Glance**

| Command | What It Does | When To Use |
|---------|-------------|-----------|
| `/lovable:init` | Set up your project | First time setup |
| `/lovable:sync` | Refresh config from Lovable Cloud | After team adds secrets/functions |
| `/lovable:deploy-edge` | Deploy edge functions | After code changes |
| `/lovable:apply-migration` | Apply database migrations | After DB changes |
| `/lovable:yolo on/off` | Toggle automation | Configure how you work |

---

## **Before & After: Real Time Savings**

### **Without This Plugin:**
```
1. Make changes in Claude Code (5 min)
2. Copy prompt to clipboard (1 min)
3. Switch to browser, open Lovable (1 min)
4. Paste prompt in chat (1 min)
5. Wait for response (2 min)
6. Manually verify (2 min)
7. Switch back to IDE (1 min)
Total: 13 minutes
```

### **With This Plugin (Manual Mode):**
```
1. Make changes in Claude Code (5 min)
2. Copy one-line prompt (30 sec)
3. Paste into Lovable (30 sec)
Total: 6 minutes
= **54% time savings**
```

### **With This Plugin (Yolo Mode):**
```
1. Make changes in Claude Code (5 min)
2. Run /lovable:deploy-edge (auto-deploys) (1 min)
Total: 6 minutes
= **54% time savings** + **zero manual work**
```

---

## **Advanced Features**

### **Yolo Mode (Auto-Deployment)**
```bash
/lovable:yolo on                    # Enable with testing
/lovable:yolo on --no-testing       # Skip tests to go faster
/lovable:yolo on --debug            # See automation logs
/lovable:yolo off                   # Disable automation
```

Yolo mode uses browser automation to:
- Navigate to your Lovable project automatically
- Submit deployment prompts without you
- Run verification tests (3 levels)
- Report success/failure instantly

### **Sync Command (Stay In Sync)**
```bash
/lovable:sync                       # Interactive (show changes, ask)
/lovable:sync --apply              # Auto-apply changes
/lovable:sync --dry-run            # Preview changes
/lovable:sync --manual             # Manual entry mode
/lovable:sync --debug              # Show detailed logs
```

Use this when:
- Team members add secrets in Lovable Cloud
- New functions are created
- You want to verify everything is aligned

---

## **The Math: Why This Plugin Pays for Itself**

- **Time saved per deployment:** ~7 minutes
- **Deployments per week (average project):** 5-10
- **Hours saved per week:** 0.6-1.2 hours
- **Hours saved per year:** 30-60 hours

That's **a full week of work back in your pocket every year.**

Plus: No more mistakes from copy-paste errors. No more forgotten secrets. No more "wait, did I deploy that?"

---

## **Troubleshooting**

**Plugin not updating?**
- Make sure marketplace auto-updates are enabled in Claude Code
- Or manually: `/plugin marketplace remove 10K-Digital/lovable-claude-code` then re-add

**Automation timing out?**
- Use manual mode: `/lovable:sync --manual`
- Or try again later (might be network/browser issue)

**Secrets not detected?**
- Run `/lovable:sync` to force a rescan
- Check that secrets use `Deno.env.get("SECRET_NAME")` pattern

---

## **What Gets Synced Automatically**

| What | Auto-Syncs | Next Step |
|------|-----------|-----------|
| React components | ✅ Yes | Just push to GitHub |
| Styling/CSS | ✅ Yes | Just push to GitHub |
| Edge Function code | ⚠️ Partially | Also run `/lovable:deploy-edge` |
| Database migrations | ⚠️ Partially | Also run `/lovable:apply-migration` |
| New tables | ❌ No | Use Lovable Cloud UI |
| RLS policies | ❌ No | Use Lovable Cloud UI |
| Secrets | ❌ No | Use Lovable Cloud UI |

---

## **Technical Details (For The Curious)**

### **How It Works Under the Hood**

This plugin provides:

**🎯 Commands** (`/lovable:*`)
- Interactive setup that scans your codebase
- Deployment helpers for Edge Functions and migrations
- Sync utility to keep config in sync with Lovable Cloud

**🧠 Skills**
- Lovable integration patterns (what syncs, what doesn't)
- Secret detection algorithms (scans code for env vars)
- Yolo mode automation (browser automation workflows)

**📋 Config Generation**
- Creates `CLAUDE.md` with project context
- Tracks secrets and their status
- Stores yolo mode preferences

### **Architecture**

```
Your IDE (Claude Code)
    ↓
lovable-claude-code plugin
    ├─ Scans your codebase
    ├─ Detects secrets & functions
    ├─ Generates exact Lovable prompts
    └─ Optionally auto-executes via browser
    ↓
GitHub (two-way sync)
    ↓
Lovable Cloud (deploys)
```

### **Security & Privacy**

- ✅ No credentials stored in the plugin
- ✅ All automation is transparent (you see what's happening)
- ✅ Manual fallback always available
- ✅ Open source ([github.com/10K-Digital/lovable-claude-code](https://github.com/10K-Digital/lovable-claude-code))

### **Browser Automation Details**

Yolo mode uses the [Claude in Chrome extension](https://chrome.google.com/webstore/detail/claude/pebppomjfocnoigkeepgbmcifnnlndla) to:
- Navigate to your Lovable project
- Interact with the chat interface
- Submit deployment prompts
- Monitor for success

**Note:** Always has manual fallback if anything goes wrong.

---

## **Files Generated**

After running `/lovable:init`, your project gets:

```
your-project/
├── CLAUDE.md              # Project configuration (edit this!)
│   ├── Production URL
│   ├── Secrets table (with status)
│   ├── Edge Functions list
│   ├── Database tables
│   ├── Project conventions
│   └── Yolo mode settings
└── ... your regular code
```

Edit `CLAUDE.md` to customize anything—Claude Code reads and respects your configuration.

---

## **Version History**

**v1.2.0** (Latest) ⭐
- Enhanced secret detection with browser automation
- New `/lovable:sync` command
- Auto-run tests support
- Better init flow

**v1.1.0**
- Yolo mode (automated deployments)
- Initial commands and skills

See [CHANGELOG.md](CHANGELOG.md) for full details.

---

## **License**

MIT—Use it however you want.

## **Contributing**

Found a bug? Have a feature request?
👉 [Open an issue](https://github.com/10K-Digital/lovable-claude-code/issues)

---

## **Made With ❤️ by 10K Digital**

Questions? [GitHub Issues](https://github.com/10K-Digital/lovable-claude-code/issues)
