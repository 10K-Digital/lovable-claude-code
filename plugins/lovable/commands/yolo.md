---
description: Enable/disable yolo mode for automated Lovable deployments with browser automation. Control auto-deploy, testing, and debug options.
---

# Yolo Mode Toggle

Enable or disable yolo mode for automated Lovable prompt submission via browser automation.

## Syntax

```bash
/yolo [on|off] [--testing|--no-testing] [--debug]
```

## Arguments

- `on` - Enable yolo mode (default: with testing, without debug; requires auto-push)
- `off` - Disable yolo mode (does not affect auto-push)
- `--testing` - Enable all 3 testing levels after deployment (default when enabling)
- `--no-testing` - Skip testing, only deploy
- `--debug` - Enable verbose logging of browser automation steps
- (no arguments) - Show current yolo mode status

**Note:** Yolo mode requires auto-push to be enabled. If auto-push is off, you'll be prompted to enable it.

## Instructions

### 1. Parse Command Arguments

Extract the mode (`on`/`off`) and flags from the command:
- If no arguments: proceed to step 7 (show status)
- If `on`: proceed to enable yolo mode
- If `off`: proceed to disable yolo mode
- Parse optional flags: `--auto-deploy`, `--no-auto-deploy`, `--testing`, `--no-testing`, `--debug`

### 2. When Enabling Yolo Mode (`/yolo on`)

**a) Show Beta Warning:**

```
⚠️ YOLO MODE (BETA)

This feature uses browser automation to automatically submit Lovable prompts.

Benefits:
✅ Auto-deploy after git push - no manual /deploy-edge command needed
✅ No manual copy-paste of prompts
✅ Automatic deployment verification
✅ Saves time on every deployment

Risks:
⚠️ Beta feature - may have bugs
⚠️ Requires Chrome extension and browser session
⚠️ Lovable UI changes may break automation
⚠️ Always has manual fallback if automation fails

Continue enabling yolo mode? (yes/no)
```

Wait for user confirmation. If no, abort.

**b) Validate Prerequisites:**

1. Check if CLAUDE.md exists:
   ```
   ❌ Cannot enable yolo mode - project not initialized
   Run /init-lovable first to set up the project.
   ```

2. Check if auto-push is enabled:
   - Read CLAUDE.md and look for "Auto-Push to GitHub: on"
   - If auto-push is off or not found, show:
     ```
     ⚠️ Yolo mode requires auto-push to be enabled

     Auto-push is currently disabled. Yolo mode needs auto-push to automatically
     commit and push your changes before triggering deployments.

     Enable auto-push now? (yes/no)
     ```
   - If user says "yes", update CLAUDE.md to enable auto-push and continue
   - If user says "no", abort yolo mode activation:
     ```
     ❌ Cannot enable yolo mode without auto-push

     To use yolo mode, auto-push must be enabled. You can:
     1. Enable auto-push manually in CLAUDE.md
     2. Run this command again and accept enabling auto-push
     ```

3. Read CLAUDE.md and check for `lovable_url` field:
   - If missing, ask user:
     ```
     What is your Lovable project URL?
     (e.g., https://lovable.dev/projects/abc123)
     ```
   - Update CLAUDE.md with provided URL

3. Check current Git branch:
   ```bash
   git branch --show-current
   ```
   - If not `main`, warn:
     ```
     ⚠️ You're on branch '[branch-name]'

     Only the main branch syncs with Lovable.
     Yolo mode will work, but deployments won't sync until you merge to main.
     ```

4. Check for Claude in Chrome extension (optional check):
   ```
   💡 Yolo mode requires the Claude in Chrome extension.

   If you don't have it installed:
   - Install: https://chrome.google.com/webstore/detail/claude/...
   - Read docs: https://docs.claude.com/claude/code-intelligence/browser-automation

   ℹ️ You can enable yolo mode now and install the extension later.
   ```

**c) Update CLAUDE.md:**

1. Read current CLAUDE.md content
2. Ensure auto-push configuration exists (should be separate from yolo mode):

```markdown
## Auto-Push Configuration

- **Auto-Push to GitHub**: on
- **Last Updated**: [current timestamp]

[... rest of auto-push section ...]
```

3. Add or update the yolo mode configuration section:

```markdown
## Yolo Mode Configuration (Beta)

> ⚠️ Beta feature - uses browser automation to auto-submit Lovable prompts
> ⚠️ Requires auto-push to be enabled

- **Status**: on
- **Deployment Testing**: [on if --testing or default, off if --no-testing]
- **Auto-run Tests**: off
- **Debug Mode**: [on if --debug, off otherwise]
- **Last Updated**: [current timestamp]
- **Operations Covered**:
  - Automatic deployment detection after git push
  - Edge function deployment
  - Migration application
  - Automated testing after code push

**Configure:** Run `/yolo on/off [--testing|--no-testing] [--debug]`
```

4. If `lovable_url` was added, update the Project Overview section

**d) Confirm Enablement:**

```
✅ Yolo mode ENABLED

Configuration:
- Testing: [✅ ON / ⏸️ OFF]
- Debug: [✅ ON / OFF]

Prerequisites:
✅ Auto-push is enabled (required for yolo mode)

Workflow:
1. You ask me to make changes
2. I complete the task successfully
3. Auto-push: I automatically commit and push to GitHub
4. Yolo mode: I detect backend changes and auto-deploy to Lovable

[if testing on] - Run 3 levels of verification tests
[if debug on] - Show verbose browser automation details

Operations automated:
✅ Automatic deployment detection after git push
✅ Edge function deployment
✅ Migration application

To disable yolo mode: /yolo off
To change settings: /yolo on --no-testing  or  /yolo on --debug
```

### 3. When Disabling Yolo Mode (`/yolo off`)

**a) Update CLAUDE.md:**

1. Read current CLAUDE.md
2. Update yolo mode configuration:
   - Set `Status: off`
   - Keep other settings for when user re-enables
   - Update `Last Updated` timestamp
3. **Do NOT change auto-push setting** - auto-push remains independent

**b) Confirm Disablement:**

```
⏸️ Yolo mode DISABLED

I'll still generate Lovable prompts for backend operations,
but you'll need to copy-paste them manually into Lovable.

Your previous settings are saved:
- Testing: [on/off]
- Debug: [on/off]

Note: Auto-push is still enabled and works independently of yolo mode.
To disable auto-push: Edit CLAUDE.md and set "Auto-Push to GitHub: off"

To re-enable yolo mode: /yolo on
```

### 4. When No Arguments (`/yolo`)

**Show Current Status:**

1. Read CLAUDE.md
2. Check if yolo mode section exists
3. Display current configuration:

If yolo mode is ON:
```
## Yolo Mode Configuration

Status: ✅ ENABLED
Auto-Deploy: [✅ ON / ⏸️ OFF] (auto-deploy after git push)
Testing: ✅ ON (runs 3 verification levels)
Debug: OFF
Last updated: 2025-01-03 10:30:00

Operations automated:
- Edge function deployment
- Migration application

[if auto-deploy on]
How it works:
- After you push backend changes to main
- I'll automatically detect and deploy them
- No need to run /deploy-edge manually!

[if auto-deploy off]
How it works:
- Run /deploy-edge or /apply-migration
- I'll navigate to Lovable and submit prompts
- Verify deployments succeed

To modify:
/yolo off                 # Disable
/yolo on --no-auto-deploy # Require manual deploy commands
/yolo on --no-testing     # Skip testing
/yolo on --debug          # Enable debug output
```

If yolo mode is OFF or not configured:
```
## Yolo Mode Configuration

Status: ⏸️ DISABLED

Yolo mode automates Lovable prompt submission using browser automation.

Benefits:
✅ Auto-deploy after git push - no manual commands needed
✅ No manual copy-paste of prompts
✅ Automatic deployment verification
✅ Saves time on every deployment

To enable: /yolo on
To learn more: Check README.md or ask "What is yolo mode?"
```

### 5. Handling Flags

**`--testing` flag (default):**
- Set `Deployment Testing: on` in CLAUDE.md
- After deployments, run all 3 testing levels:
  - Level 1: Basic verification
  - Level 2: Console error checking
  - Level 3: Functional testing

**`--no-testing` flag:**
- Set `Deployment Testing: off` in CLAUDE.md
- After deployments, skip all testing
- Only deploy and confirm basic success

**`--debug` flag:**
- Set `Debug Mode: on` in CLAUDE.md
- During browser automation, output verbose logs:
  - Each navigation step
  - Element selectors used
  - Wait times and conditions
  - Full response text from Lovable

### 6. Error Handling

**CLAUDE.md not found:**
```
❌ Cannot configure yolo mode

CLAUDE.md not found. Initialize the project first:
/init-lovable
```

**Invalid arguments:**
```
❌ Invalid syntax

Usage: /yolo [on|off] [--auto-deploy|--no-auto-deploy] [--testing|--no-testing] [--debug]

Examples:
  /yolo                    # Show status
  /yolo on                 # Enable with auto-deploy and testing
  /yolo on --no-auto-deploy # Enable without auto-deploy
  /yolo on --debug         # Enable with debug logs
  /yolo off                # Disable
```

**Conflicting flags:**
```
❌ Cannot use --testing and --no-testing together

Choose one:
  /yolo on --testing     # Enable testing (default)
  /yolo on --no-testing  # Skip testing
```

### 7. Integration Notes

**Relationship with auto-push:**
- Auto-push and yolo mode are configured separately in CLAUDE.md
- Auto-push can be on while yolo mode is off (manual deployment workflow)
- Yolo mode REQUIRES auto-push to be on (enforced when enabling)
- Disabling yolo mode does NOT disable auto-push

**Workflow when yolo mode is enabled:**
After a successful `git push origin main` (triggered by auto-push) that includes backend changes:
- Claude automatically detects edge function or migration changes
- Triggers browser automation without manual command
- Deploys to Lovable and runs verification tests

**Manual deployment with yolo mode:**
Even with yolo mode on, you can still manually trigger deployments:
- `/deploy-edge` - Deploys edge functions to Lovable
- `/apply-migration` - Applies database migrations

The automation workflow is defined in `/skills/yolo/SKILL.md` and references.
See `/skills/yolo/references/post-push-automation.md` for auto-deploy implementation.

## Example Outputs

### Example 1: First-time Enable

```
$ /yolo on

⚠️ YOLO MODE (BETA)

This feature uses browser automation to automatically submit Lovable prompts.

Benefits:
✅ Auto-deploy after git push - no manual /deploy-edge command needed
✅ No manual copy-paste of prompts
✅ Automatic deployment verification
✅ Saves time on every deployment

Risks:
⚠️ Beta feature - may have bugs
⚠️ Requires Chrome extension and browser session
⚠️ Lovable UI changes may break automation
⚠️ Always has manual fallback if automation fails

Continue enabling yolo mode? yes

What is your Lovable project URL?
(e.g., https://lovable.dev/projects/abc123)
> https://lovable.dev/projects/my-project

✅ Yolo mode ENABLED

Configuration:
- Auto-Deploy: ✅ ON (deploy automatically after git push)
- Testing: ✅ ON
- Debug: OFF

From now on, after you push backend changes to main:
- I'll automatically detect edge function or migration changes
- Navigate to your Lovable project
- Submit the deployment prompts for you
- No need to run /deploy-edge manually!
- Run 3 levels of verification tests

Operations automated:
✅ Edge function deployment
✅ Migration application

To disable: /yolo off
```

### Example 2: Enable Without Auto-Deploy

```
$ /yolo on --no-auto-deploy

⚠️ YOLO MODE (BETA)
[... beta warning ...]

Continue enabling yolo mode? yes

✅ Yolo mode ENABLED

Configuration:
- Auto-Deploy: ⏸️ OFF (run /deploy-edge manually)
- Testing: ✅ ON
- Debug: OFF

When you run /deploy-edge or /apply-migration:
- I'll navigate to Lovable and submit prompts
- Run verification tests

Operations automated:
✅ Edge function deployment
✅ Migration application

To enable auto-deploy: /yolo on --auto-deploy
```

### Example 3: Enable Without Testing

```
$ /yolo on --no-testing

⚠️ YOLO MODE (BETA)
[... beta warning ...]

Continue enabling yolo mode? yes

✅ Yolo mode ENABLED

Configuration:
- Auto-Deploy: ✅ ON
- Testing: ⏸️ OFF (deployments only, no verification tests)
- Debug: OFF

Operations automated:
✅ Edge function deployment (no testing)
✅ Migration application (no testing)

To enable testing: /yolo on --testing
```

### Example 4: Enable with Debug

```
$ /yolo on --debug

⚠️ YOLO MODE (BETA)
[... beta warning ...]

Continue enabling yolo mode? yes

✅ Yolo mode ENABLED

Configuration:
- Auto-Deploy: ✅ ON
- Testing: ✅ ON
- Debug: ✅ ON (verbose browser automation logs)

You'll see detailed output during deployments:
- Navigation steps
- Element selectors
- Response text
- Timing information

To disable debug: /yolo on
```

### Example 5: Check Status

```
$ /yolo

## Yolo Mode Configuration

Status: ✅ ENABLED
Auto-Deploy: ✅ ON (auto-deploy after git push)
Testing: ✅ ON (runs 3 verification levels)
Debug: ✅ ON
Last updated: 2025-01-03 10:30:00

Operations automated:
- Edge function deployment
- Migration application

How it works:
- After you push backend changes to main
- I'll automatically detect and deploy them
- No need to run /deploy-edge manually!

To modify:
/yolo off                 # Disable
/yolo on --no-auto-deploy # Require manual deploy commands
/yolo on --no-testing     # Skip testing
/yolo on                  # Disable debug (keeps auto-deploy and testing)
```

### Example 6: Disable

```
$ /yolo off

⏸️ Yolo mode DISABLED

I'll still generate Lovable prompts for backend operations,
but you'll need to copy-paste them manually into Lovable.

Your previous settings are saved:
- Auto-Deploy: on
- Testing: on
- Debug: on

To re-enable: /yolo on
```
